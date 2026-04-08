using AiSupportDesk.Api.Data;
using AiSupportDesk.Api.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using System.Text.Json;

namespace AiSupportDesk.Functions;

public class TicketAiProcessor(
    TicketsDbContext db,
    Kernel kernel,
    IConfiguration configuration,
    ILogger<TicketAiProcessor> logger)
{
    private const string SystemPrompt =
        """
        You are a helpful support desk assistant.
        When given a support ticket, respond with ONLY valid JSON in this exact shape:
        {"suggestedReply":"<your reply to the user>","category":"<Billing|Technical|General>"}
        Do not include any markdown, explanation, or extra text outside the JSON.
        """;

    [Function("ProcessTicket")]
    public async Task Run(
        [ServiceBusTrigger("%ServiceBus__QueueName%", Connection = "ServiceBus__ConnectionString")] string ticketIdMessage,
        CancellationToken cancellationToken)
    {
        if (!Guid.TryParse(ticketIdMessage.Trim('"'), out var ticketId))
        {
            logger.LogError("Received invalid ticket ID: {Message}", ticketIdMessage);
            return;
        }

        var ticket = await db.Tickets.FirstOrDefaultAsync(t => t.Id == ticketId, cancellationToken);
        if (ticket is null)
        {
            logger.LogWarning("Ticket {TicketId} not found.", ticketId);
            return;
        }

        logger.LogInformation("Processing ticket {TicketId}: {Title}", ticket.Id, ticket.Title);

        var chatService = kernel.GetRequiredService<IChatCompletionService>();
        var history = new ChatHistory(SystemPrompt);
        history.AddUserMessage($"Title: {ticket.Title}\n\nDescription: {ticket.Description}");

        var result = await chatService.GetChatMessageContentAsync(history, cancellationToken: cancellationToken);
        var raw = result.Content ?? string.Empty;

        AiResult? parsed = null;
        try
        {
            parsed = JsonSerializer.Deserialize<AiResult>(raw, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
        }
        catch (JsonException ex)
        {
            logger.LogError(ex, "Failed to parse AI response for ticket {TicketId}. Raw: {Raw}", ticketId, raw);
        }

        ticket.AiSuggestedReply = parsed?.SuggestedReply ?? raw;
        ticket.Category = Enum.TryParse<TicketCategory>(parsed?.Category, ignoreCase: true, out var cat)
            ? cat
            : TicketCategory.General;
        ticket.Status = TicketStatus.Processing;
        ticket.UpdatedAt = DateTime.UtcNow;

        await db.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Ticket {TicketId} updated. Category={Category}", ticketId, ticket.Category);

        // Notify Logic App for email routing
        var logicAppUrl = configuration["LogicApp:TriggerUrl"];
        if (!string.IsNullOrEmpty(logicAppUrl))
        {
            using var http = new HttpClient();
            var payload = JsonSerializer.Serialize(new
            {
                ticketId = ticket.Id,
                category = ticket.Category.ToString(),
                title = ticket.Title
            });
            await http.PostAsync(logicAppUrl,
                new StringContent(payload, System.Text.Encoding.UTF8, "application/json"),
                cancellationToken);
        }
    }

    private record AiResult(string SuggestedReply, string Category);
}
