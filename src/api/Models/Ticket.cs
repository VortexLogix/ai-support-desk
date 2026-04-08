namespace AiSupportDesk.Api.Models;

public enum TicketCategory
{
    Unclassified,
    Billing,
    Technical,
    General
}

public enum TicketStatus
{
    Open,
    Processing,
    Resolved
}

public class Ticket
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public TicketCategory Category { get; set; } = TicketCategory.Unclassified;
    public TicketStatus Status { get; set; } = TicketStatus.Open;
    public string UserId { get; set; } = string.Empty;
    public string? AiSuggestedReply { get; set; }
    public string? ApprovedReply { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
