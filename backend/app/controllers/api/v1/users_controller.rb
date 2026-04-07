module Api
  module V1
    class UsersController < BaseController
      def me
        render json: {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email,
          created_at: current_user.created_at
        }
      end
    end
  end
end
