class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)
    resource.save

    if resource.persisted?
      render json: {
        message: "Cadastro realizado com sucesso.",
        user: {
          id: resource.id,
          name: resource.name,
          email: resource.email
        }
      }, status: :created
    else
      clean_up_passwords resource
      set_minimum_password_length

      render json: {
        message: "Erro ao criar conta.",
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

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
