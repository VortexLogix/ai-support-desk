using AiSupportDesk.Api.Dtos;
using AiSupportDesk.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace AiSupportDesk.Api.Controllers;

[ApiController]
[Route("auth")]
public class AuthController(IConfiguration configuration, JwtService jwtService) : ControllerBase
{
    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest request)
    {
        var users = configuration.GetSection("Users").Get<List<HardcodedUser>>();
        if (users is null)
            return StatusCode(500, "Users not configured.");

        var match = users.FirstOrDefault(u =>
            string.Equals(u.Username, request.Username, StringComparison.OrdinalIgnoreCase));

        if (match is null || !BCrypt.Net.BCrypt.Verify(request.Password, match.PasswordHash))
            return Unauthorized(new { message = "Invalid username or password." });

        var token = jwtService.GenerateToken(match);
        return Ok(new LoginResponse(token, match.Role, match.Username));
    }
}
