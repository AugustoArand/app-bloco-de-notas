allowed_origins = [
  "http://localhost:5173",
  "http://127.0.0.1:5173",
  /\Ahttps:\/\/.*\.vercel\.app\z/
]

allowed_origins << ENV["FRONTEND_URL"].strip if ENV["FRONTEND_URL"].present?

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
