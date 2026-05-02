class Rack::Attack
  # Throttle POST /links to 10 requests per minute per IP.
  # Increase limit or period by adjusting the values below.
  throttle("links/create/ip", limit: 10, period: 60) do |req|
    req.ip if req.post? && req.path == "/links"
  end

  self.throttled_responder = lambda do |_req|
    [
      429,
      { "Content-Type" => "text/plain" },
      [ "Rate limit exceeded. Please wait before creating more short URLs." ]
    ]
  end
end

# Disable throttling in the test environment so existing request tests are
# unaffected. The rack_attack_test.rb re-enables it for its own assertions.
Rack::Attack.enabled = false if Rails.env.test?
