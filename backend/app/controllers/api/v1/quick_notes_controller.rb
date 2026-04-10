module Api
  module V1
    class QuickNotesController < BaseController
      before_action :set_quick_note, only: [:update, :destroy]

      def index
        render json: current_user.quick_notes.map { |qn| quick_note_json(qn) }
      end

      def create
        @quick_note = current_user.quick_notes.build(quick_note_params)
        if @quick_note.save
          render json: quick_note_json(@quick_note), status: :created
        else
          render json: { errors: @quick_note.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @quick_note.update(quick_note_params)
          render json: quick_note_json(@quick_note)
        else
          render json: { errors: @quick_note.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @quick_note.destroy
        render json: { message: "Anotação removida." }
      end

      private

      def set_quick_note
        @quick_note = current_user.quick_notes.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def quick_note_params
        params.require(:quick_note).permit(:title, :text, :color, :position)
      end

      def quick_note_json(qn)
        {
          id:         qn.id,
          title:      qn.title,
          text:       qn.text,
          color:      qn.color,
          position:   qn.position,
          created_at: qn.created_at,
          updated_at: qn.updated_at
        }
      end
    end
  end
end
