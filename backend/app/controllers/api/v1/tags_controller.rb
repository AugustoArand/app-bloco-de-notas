module Api
  module V1
    class TagsController < BaseController
      before_action :set_tag, only: [:update, :destroy]

      def index
        @tags = current_user.tags
        render json: @tags.map { |tag| tag_json(tag) }
      end

      def create
        @tag = current_user.tags.build(tag_params)
        if @tag.save
          render json: tag_json(@tag), status: :created
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @tag.update(tag_params)
          render json: tag_json(@tag)
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @tag.destroy
        render json: { message: "Tag removida com sucesso." }
      end

      private

      def set_tag
        @tag = current_user.tags.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def tag_params
        params.require(:tag).permit(:name, :color)
      end

      def tag_json(tag)
        {
          id: tag.id,
          name: tag.name,
          color: tag.color,
          notes_count: tag.notes.count
        }
      end
    end
  end
end
