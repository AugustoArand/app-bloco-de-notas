module Api
  module V1
    class NotebooksController < BaseController
      before_action :set_notebook, only: [:show, :update, :destroy]

      def index
        @notebooks = current_user.notebooks
        render json: @notebooks.map { |nb| notebook_json(nb) }
      end

      def show
        render json: notebook_json(@notebook)
      end

      def create
        @notebook = current_user.notebooks.build(notebook_params)
        if @notebook.save
          render json: notebook_json(@notebook), status: :created
        else
          render json: { errors: @notebook.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @notebook.update(notebook_params)
          render json: notebook_json(@notebook)
        else
          render json: { errors: @notebook.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @notebook.destroy
        render json: { message: "Caderno removido com sucesso." }
      end

      private

      def set_notebook
        @notebook = current_user.notebooks.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def notebook_params
        params.require(:notebook).permit(:name, :favorite)
      end

      def notebook_json(notebook)
        {
          id: notebook.id,
          name: notebook.name,
          favorite: notebook.favorite,
          notes_count: notebook.notes.count,
          created_at: notebook.created_at,
          updated_at: notebook.updated_at
        }
      end
    end
  end
end
