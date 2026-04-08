using AiSupportDesk.Api.Data;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.SemanticKernel;

var builder = FunctionsApplication.CreateBuilder(args);

builder.ConfigureFunctionsWebApplication();

// ── Database ──────────────────────────────────────────────────────────────────
builder.Services.AddDbContext<TicketsDbContext>(options =>
    options.UseSqlServer(builder.Configuration["SqlConnectionString"]));

// ── Semantic Kernel ───────────────────────────────────────────────────────────
builder.Services.AddTransient(sp =>
{
    var config = builder.Configuration;
    return Kernel.CreateBuilder()
        .AddAzureOpenAIChatCompletion(
            deploymentName: config["AzureOpenAi:DeploymentName"] ?? "gpt-4o",
            endpoint: config["AzureOpenAi:Endpoint"] ?? string.Empty,
            apiKey: config["AzureOpenAi:ApiKey"] ?? string.Empty)
        .Build();
});

builder.Services
    .AddApplicationInsightsTelemetryWorkerService()
    .ConfigureFunctionsApplicationInsights();

builder.Build().Run();
