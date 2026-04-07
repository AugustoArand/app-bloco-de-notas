module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      private

      def not_found
        render json: { error: "Recurso não encontrado." }, status: :not_found
      end

      def unauthorized
        render json: { error: "Não autorizado." }, status: :unauthorized
      end
    end
  end
end
