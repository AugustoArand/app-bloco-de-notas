module Api
  module V1
    class UsersController < BaseController
      def me
        render json: user_json(current_user)
      end

      def upload_cover
        image = params[:image]

        if image.blank?
          return render json: { errors: ["Imagem não enviada."] }, status: :unprocessable_entity
        end

        current_user.cover_image.purge if current_user.cover_image.attached?
        current_user.cover_image.attach(image)

        render json: {
          cover_image_url: absolute_asset_url(current_user.cover_image),
          user: user_json(current_user)
        }, status: :created
      rescue StandardError => e
        Rails.logger.error("upload_cover falhou: #{e.class} - #{e.message}")
        render json: { errors: ["Falha ao fazer upload da capa."] }, status: :internal_server_error
      end

      def remove_cover
        current_user.cover_image.purge if current_user.cover_image.attached?
        render json: { user: user_json(current_user), cover_image_url: nil }, status: :ok
      end

      private

      def user_json(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          cover_image_url: user.cover_image.attached? ? absolute_asset_url(user.cover_image) : nil,
          created_at: user.created_at
        }
      end

      def absolute_asset_url(asset)
        generated = url_for(asset)
        return generated if generated.start_with?("http://", "https://")

        "#{request.base_url}#{generated}"
      end
    end
  end
end
