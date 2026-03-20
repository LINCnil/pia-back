class Rack::Attack
  # Throttle OAuth token requests (login) - 5 requests per 15 minutes per IP
  throttle("oauth/token/ip", limit: 5, period: 15.minutes) do |req|
    req.ip if req.path == "/oauth/token" && req.post?
  end

  # Throttle password reset requests - 3 per hour per IP
  throttle("password_forgotten/ip", limit: 3, period: 1.hour) do |req|
    req.ip if req.path == "/users/password-forgotten" && req.post?
  end

  # Throttle password reset requests - 3 per hour per email
  throttle("password_forgotten/email", limit: 3, period: 1.hour) do |req|
    if req.path == "/users/password-forgotten" && req.post?
      req.params.dig("email").to_s.downcase.strip.presence
    end
  end

  # Throttle password change attempts - 5 per hour per IP
  throttle("change_password/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users/change-password" && req.put?
  end

  # Global throttle - 300 requests per 5 minutes per IP
  throttle("req/ip", limit: 300, period: 5.minutes, &:ip)

  # Return 429 Too Many Requests with JSON body
  self.throttled_responder = lambda do |matched, period, limit, request|
    now = Time.now.utc
    retry_after = (period - (now.to_i % period)).to_s

    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after
    }

    body = { error: "Rate limit exceeded. Try again in #{retry_after} seconds." }.to_json

    [429, headers, [body]]
  end
end
