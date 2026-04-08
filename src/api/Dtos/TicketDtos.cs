namespace AiSupportDesk.Api.Dtos;

public record LoginRequest(string Username, string Password);
public record LoginResponse(string Token, string Role, string Username);

public record CreateTicketRequest(string Title, string Description);

public record TicketResponse(
    Guid Id,
    string Title,
    string Description,
    string Category,
    string Status,
    string UserId,
    string? AiSuggestedReply,
    string? ApprovedReply,
    DateTime CreatedAt,
    DateTime UpdatedAt);

public record PatchTicketRequest(string? ApprovedReply, bool Resolve);
