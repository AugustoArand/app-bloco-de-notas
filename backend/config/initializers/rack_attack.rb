require "time"

class Rack::Attack
  # Keep throttling independent from Rails.cache backends (e.g. Solid Cache/DB)
  # so auth does not fail if cache services are unavailable.
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Login endpoint gets a tighter limit to reduce brute-force attempts.
  throttle("auth/sign_in/ip", limit: 10, period: 60.seconds) do |req|
    req.ip if req.path == "/auth/sign_in" && req.post?
  end

  # Global API throttle per IP to reduce abuse and simple DoS attempts.
  throttle("api/v1/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/v1/")
  end

  self.throttled_responder = lambda do |request|
    now = Time.now.utc
    match_data = request.env["rack.attack.match_data"] || {}
    retry_after = match_data[:period].to_i

    body = {
      error: "Muitas requisicoes. Tente novamente em instantes.",
      retry_after: retry_after,
      timestamp: now.iso8601
    }.to_json

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [body]
    ]
  end
end
