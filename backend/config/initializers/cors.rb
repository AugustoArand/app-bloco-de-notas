Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allowed_origins = ENV.fetch("CORS_ALLOWED_ORIGINS", "")
                       .split(",")
                       .map(&:strip)
                       .reject(&:blank?)

  frontend_url = ENV["FRONTEND_URL"].to_s.strip
  allowed_origins << frontend_url if frontend_url.present?

  # Production fallback to the known app URL when env vars are missing.
  if allowed_origins.empty?
    allowed_origins << "https://app-bloco-de-notas.vercel.app"
  end

  # Allow local frontends only in development/test.
  if Rails.env.development? || Rails.env.test?
    allowed_origins.concat([
      "http://localhost:5173",
      "http://127.0.0.1:5173"
    ])
  end

  allowed_origins.uniq!

  allow do
    origins do |origin, _env|
      begin
        next false if origin.blank?

        allowed_origins.include?(origin.strip)
      rescue StandardError => e
        Rails.logger.warn("CORS origin check failed: #{e.class} - #{e.message}")
        false
      end
    end

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"],
      max_age: 600
  end
end
