class AppCors
  ALLOWED_ORIGINS = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "https://app-bloco-de-notas.vercel.app"
  ].freeze

  CORS_HEADERS = {
    "Access-Control-Allow-Methods"  => "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD",
    "Access-Control-Allow-Headers"  => "Content-Type, Authorization, Accept",
    "Access-Control-Expose-Headers" => "Authorization",
    "Access-Control-Max-Age"        => "600"
  }.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    origin = env["HTTP_ORIGIN"]

    unless allowed?(origin)
      return @app.call(env)
    end

    cors = CORS_HEADERS.merge("Access-Control-Allow-Origin" => origin)

    if env["REQUEST_METHOD"] == "OPTIONS"
      return [200, cors.merge("Content-Type" => "text/plain"), [""]]
    end

    status, headers, body = @app.call(env)
    [status, headers.merge(cors), body]
  end

  private

  def allowed?(origin)
    return false if origin.nil? || origin.empty?
    ALLOWED_ORIGINS.include?(origin) ||
      origin.match?(/\Ahttps:\/\/[^.]+\.vercel\.app\z/) ||
      (!ENV["FRONTEND_URL"].to_s.strip.empty? && origin == ENV["FRONTEND_URL"].strip)
  end
end

Rails.application.config.middleware.insert_before 0, AppCors
