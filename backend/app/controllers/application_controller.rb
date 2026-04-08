class ApplicationController < ActionController::API
  before_action :authenticate_user!, unless: -> { request.method == "OPTIONS" }
  after_action :set_cors_headers

  private

  def current_user_from_token
    current_user
  end

  def set_cors_headers
    origin = request.headers["Origin"]
    return unless origin.present?

    response.headers["Access-Control-Allow-Origin"]   = origin
    response.headers["Access-Control-Allow-Methods"]  = "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD"
    response.headers["Access-Control-Allow-Headers"]  = "Content-Type, Authorization, Accept"
    response.headers["Access-Control-Expose-Headers"] = "Authorization"
  end
end
