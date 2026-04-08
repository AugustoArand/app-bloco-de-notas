Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |origin, _env|
      next false if origin.blank?

      normalized_origin = origin.strip
      frontend_url = ENV["FRONTEND_URL"].to_s.strip

      explicit_origins = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "https://app-bloco-de-notas.vercel.app"
      ]

      explicit_origins.include?(normalized_origin) ||
        normalized_origin.match?(/\Ahttps:\/\/[^.]+\.vercel\.app\z/) ||
        (frontend_url.present? && normalized_origin == frontend_url)
    end

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"],
      max_age: 600
  end
end
