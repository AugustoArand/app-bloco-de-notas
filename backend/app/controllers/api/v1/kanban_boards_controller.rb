module Api
  module V1
    class KanbanBoardsController < BaseController
      before_action :set_board, only: [:update, :destroy]

      def index
        boards = current_user.kanban_boards.includes(:kanban_tasks)

        if boards.empty?
          bootstrap_default_boards!
          boards = current_user.kanban_boards.includes(:kanban_tasks)
        end

        render json: boards.map { |board| board_json(board) }
      end

      def create
        board = current_user.kanban_boards.build(board_params)
        board.position = current_user.kanban_boards.maximum(:position).to_i + 1 if board.position.nil?

        if board.save
          render json: board_json(board), status: :created
        else
          render json: { errors: board.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @board.update(board_params)
          normalize_board_positions!
          render json: board_json(@board.reload)
        else
          render json: { errors: @board.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if current_user.kanban_boards.count <= 1
          return render json: { errors: ['Mantenha ao menos um board.'] }, status: :unprocessable_entity
        end

        ActiveRecord::Base.transaction do
          destination = current_user.kanban_boards
                                    .where.not(id: @board.id)
                                    .order(position: :asc)
                                    .where('position <= ?', @board.position)
                                    .last

          destination ||= current_user.kanban_boards.where.not(id: @board.id).order(position: :asc).first

          @board.kanban_tasks.order(position: :asc).each do |task|
            task.update!(kanban_board: destination, position: destination.kanban_tasks.maximum(:position).to_i + 1)
          end

          @board.destroy!
          normalize_board_positions!
        end

        render json: { message: 'Board removido com sucesso.' }
      end

      private

      def set_board
        @board = current_user.kanban_boards.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def board_params
        params.require(:kanban_board).permit(:title, :position)
      end

      def board_json(board)
        {
          id: board.id,
          title: board.title,
          position: board.position,
          cards: board.kanban_tasks.active.order(position: :asc).map { |task| task_json(task) },
          created_at: board.created_at,
          updated_at: board.updated_at
        }
      end

      def task_json(task)
        {
          id: task.id,
          title: task.title,
          description: task.description,
          position: task.position,
          kanban_board_id: task.kanban_board_id,
          created_at: task.created_at,
          updated_at: task.updated_at
        }
      end

      def bootstrap_default_boards!
        %w[Backlog Em\ progresso Concluido].each_with_index do |title, index|
          current_user.kanban_boards.create!(title: title, position: index)
        end
      end

      def normalize_board_positions!
        current_user.kanban_boards.order(position: :asc, created_at: :asc).each_with_index do |board, index|
          board.update_column(:position, index)
        end
      end
    end
  end
end
