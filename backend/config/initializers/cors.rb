allowed_origins = [
  "http://localhost:5173",
  "http://127.0.0.1:5173"
]

if (frontend_url = ENV["FRONTEND_URL"].to_s.strip) && !frontend_url.empty?
  allowed_origins << frontend_url
end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"],
      max_age: 600
  end
end
