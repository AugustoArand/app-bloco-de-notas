class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def user_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      cover_image_url: user.cover_image.attached? ? url_for(user.cover_image) : nil
    }
  end

  def respond_with(resource, _opts = {})
    render json: {
      message: "Login realizado com sucesso.",
      user: user_json(resource)
    }, status: :ok
  end

  def respond_to_on_destroy
    render json: { message: "Logout realizado com sucesso." }, status: :ok
  end
end
