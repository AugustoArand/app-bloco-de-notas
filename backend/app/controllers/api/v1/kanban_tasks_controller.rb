module Api
  module V1
    class KanbanTasksController < BaseController
      before_action :set_board, only: [:create]
      before_action :set_task, only: [:update, :destroy]

      def create
        task = @board.kanban_tasks.build(task_params.except(:position, :kanban_board_id))
        task.position = @board.kanban_tasks.maximum(:position).to_i + 1

        if task.save
          render json: task_json(task), status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        old_board = @task.kanban_board
        target_board = target_board_for_update
        new_position = params.dig(:kanban_task, :position)

        ActiveRecord::Base.transaction do
          @task.assign_attributes(task_params.except(:position, :kanban_board_id))
          @task.kanban_board = target_board if target_board
          @task.save!

          place_task!(@task, target_board || old_board, new_position)

          normalize_task_positions!(old_board)
          normalize_task_positions!(@task.kanban_board) if @task.kanban_board_id != old_board.id
        end

        render json: task_json(@task.reload)
      rescue ActiveRecord::RecordInvalid
        render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
      end

      def destroy
        board = @task.kanban_board
        @task.destroy
        normalize_task_positions!(board)
        render json: { message: 'Tarefa removida com sucesso.' }
      end

      private

      def set_board
        @board = current_user.kanban_boards.find(params[:kanban_board_id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def set_task
        @task = current_user.kanban_tasks.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      def task_params
        params.require(:kanban_task).permit(:title, :description, :position, :kanban_board_id)
      end

      def target_board_for_update
        target_id = params.dig(:kanban_task, :kanban_board_id)
        return nil if target_id.blank?

        current_user.kanban_boards.find(target_id)
      end

      def place_task!(task, board, new_position)
        return unless board

        max_index = board.kanban_tasks.where.not(id: task.id).count
        desired_index = new_position.to_i
        desired_index = 0 if desired_index.negative?
        desired_index = max_index if desired_index > max_index

        board.kanban_tasks.where.not(id: task.id).order(position: :asc, created_at: :asc).each_with_index do |item, index|
          item.update_column(:position, index >= desired_index ? index + 1 : index)
        end

        task.update_column(:position, desired_index)
      end

      def normalize_task_positions!(board)
        board.kanban_tasks.order(position: :asc, created_at: :asc).each_with_index do |task, index|
          task.update_column(:position, index)
        end
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
    end
  end
end
