using AiSupportDesk.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AiSupportDesk.Api.Data;

public class TicketsDbContext(DbContextOptions<TicketsDbContext> options) : DbContext(options)
{
    public DbSet<Ticket> Tickets => Set<Ticket>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Ticket>(e =>
        {
            e.HasKey(t => t.Id);
            e.Property(t => t.Title).HasMaxLength(200).IsRequired();
            e.Property(t => t.Description).HasMaxLength(4000).IsRequired();
            e.Property(t => t.UserId).HasMaxLength(100).IsRequired();
            e.Property(t => t.AiSuggestedReply).HasMaxLength(4000);
            e.Property(t => t.ApprovedReply).HasMaxLength(4000);
            e.Property(t => t.Category).HasConversion<string>().HasMaxLength(20);
            e.Property(t => t.Status).HasConversion<string>().HasMaxLength(20);
        });
    }
}
