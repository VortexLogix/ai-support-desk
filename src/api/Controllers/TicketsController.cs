using System.Security.Claims;
using AiSupportDesk.Api.Data;
using AiSupportDesk.Api.Dtos;
using AiSupportDesk.Api.Models;
using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AiSupportDesk.Api.Controllers;

[ApiController]
[Route("tickets")]
[Authorize]
public class TicketsController(
    TicketsDbContext db,
    ServiceBusClient serviceBusClient,
    IConfiguration configuration,
    ILogger<TicketsController> logger) : ControllerBase
{
    private string CurrentUserId =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;

    private bool IsAdmin =>
        User.IsInRole("admin");

    private static TicketResponse MapToResponse(Ticket t) =>
        new(t.Id, t.Title, t.Description, t.Category.ToString(),
            t.Status.ToString(), t.UserId, t.AiSuggestedReply, t.ApprovedReply,
            t.CreatedAt, t.UpdatedAt);

    [HttpPost]
    [Authorize(Roles = "user")]
    public async Task<IActionResult> CreateTicket([FromBody] CreateTicketRequest request, CancellationToken ct)
    {
        var ticket = new Ticket
        {
            Title = request.Title,
            Description = request.Description,
            UserId = CurrentUserId
        };

        db.Tickets.Add(ticket);
        await db.SaveChangesAsync(ct);

        try
        {
            var queueName = configuration["ServiceBus:QueueName"] ?? "tickets";
            var sender = serviceBusClient.CreateSender(queueName);
            await sender.SendMessageAsync(
                new ServiceBusMessage(ticket.Id.ToString()), ct);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to publish ticket {TicketId} to Service Bus.", ticket.Id);
            // Ticket is already saved; SB publish failure is non-fatal for the response
        }

        return CreatedAtAction(nameof(GetTicket), new { id = ticket.Id }, MapToResponse(ticket));
    }

    [HttpGet]
    public async Task<IActionResult> GetTickets(CancellationToken ct)
    {
        var query = db.Tickets.AsNoTracking();
        if (!IsAdmin)
            query = query.Where(t => t.UserId == CurrentUserId);

        var tickets = await query
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => MapToResponse(t))
            .ToListAsync(ct);

        return Ok(tickets);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetTicket(Guid id, CancellationToken ct)
    {
        var ticket = await db.Tickets.AsNoTracking()
            .FirstOrDefaultAsync(t => t.Id == id, ct);

        if (ticket is null)
            return NotFound();

        if (!IsAdmin && ticket.UserId != CurrentUserId)
            return Forbid();

        return Ok(MapToResponse(ticket));
    }

    [HttpPatch("{id:guid}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> PatchTicket(Guid id, [FromBody] PatchTicketRequest request, CancellationToken ct)
    {
        var ticket = await db.Tickets.FirstOrDefaultAsync(t => t.Id == id, ct);
        if (ticket is null)
            return NotFound();

        if (request.ApprovedReply is not null)
            ticket.ApprovedReply = request.ApprovedReply;

        if (request.Resolve)
            ticket.Status = TicketStatus.Resolved;

        ticket.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);

        return Ok(MapToResponse(ticket));
    }
}
