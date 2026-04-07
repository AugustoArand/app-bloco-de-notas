class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if request.method == "DELETE"
      render json: { message: "Conta removida com sucesso." }, status: :ok
    elsif resource.persisted?
      render json: {
        message: "Cadastro realizado com sucesso.",
        user: {
          id: resource.id,
          name: resource.name,
          email: resource.email
        }
      }, status: :created
    else
      render json: {
        message: "Erro ao criar conta.",
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
