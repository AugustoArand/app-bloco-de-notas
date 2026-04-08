module Api
  module V1
    class NotesController < BaseController
      before_action :set_notebook, only: [:index, :create]
      before_action :set_note, only: [:show, :update, :destroy]

      def index
        @notes = @notebook.notes
        @notes = @notes.search(params[:q]) if params[:q].present?
        render json: @notes.map { |note| note_summary_json(note) }
      end

      def recent
        @notes = current_user.notes
                             .unscoped
                             .joins(notebook: :user)
                             .where(notebooks: { user_id: current_user.id })
                             .where.not(accessed_at: nil)
                             .order(accessed_at: :desc)
                             .limit(8)

        render json: @notes.map { |note| note_summary_json(note) }
      end

      def show
        @note.touch_accessed!
        render json: note_full_json(@note)
      end

      def create
        @note = @notebook.notes.build(note_params)
        if @note.save
          render json: note_full_json(@note), status: :created
        else
          render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        tag_ids = params.dig(:note, :tag_ids)

        if @note.update(note_params)
          # Sync tags if provided
          if tag_ids
            valid_tag_ids = current_user.tags.where(id: tag_ids).pluck(:id)
            @note.tag_ids = valid_tag_ids
          end
          render json: note_full_json(@note)
        else
          render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @note.destroy
        render json: { message: "Nota removida com sucesso." }
      end

      def upload_image
        @note = current_user.notes.find(params[:id])
        image = params[:image]

        if image.blank?
          return render json: { errors: ["Imagem não enviada."] }, status: :unprocessable_entity
        end

        @note.images.attach(image)
        url = absolute_asset_url(@note.images.last)
        render json: { url: url }, status: :created
      rescue ActiveRecord::RecordNotFound
        not_found
      rescue StandardError => e
        Rails.logger.error("upload_image falhou: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace&.first(8)&.join("\n"))
        render json: { errors: ["Falha ao fazer upload da imagem."] }, status: :internal_server_error
      end

      private

      def set_notebook
        @notebook = current_user.notebooks.find(params[:notebook_id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def set_note
        @note = current_user.notes.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def note_params
        params.require(:note).permit(:title, :content)
      end

      def note_summary_json(note)
        {
          id: note.id,
          title: note.title,
          excerpt: note.content.to_s.gsub(/<[^>]*>/, '').truncate(140),
          notebook_id: note.notebook_id,
          notebook_name: note.notebook.name,
          tags: note.tags.map { |t| { id: t.id, name: t.name, color: t.color } },
          accessed_at: note.accessed_at,
          created_at: note.created_at,
          updated_at: note.updated_at
        }
      end

      def note_full_json(note)
        images = note.images.map do |img|
          { id: img.id, url: absolute_asset_url(img) }
        end

        {
          id: note.id,
          title: note.title,
          content: note.content,
          notebook_id: note.notebook_id,
          notebook_name: note.notebook.name,
          tags: note.tags.map { |t| { id: t.id, name: t.name, color: t.color } },
          images: images,
          accessed_at: note.accessed_at,
          created_at: note.created_at,
          updated_at: note.updated_at
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
