Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |source, _env|
      source == "http://localhost:5173" ||
        source == "http://127.0.0.1:5173" ||
        source.match?(/\Ahttps:\/\/[^.]+\.vercel\.app\z/) ||
        (ENV["FRONTEND_URL"].present? && source == ENV["FRONTEND_URL"].strip)
    end

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"],
      max_age: 600
  end
end
