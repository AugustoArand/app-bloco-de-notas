class ApplicationController < ActionController::API
  before_action :authenticate_user!, unless: -> { request.method == "OPTIONS" }

  def current_user_from_token
    current_user
  end
end
