module Api
  module V1
    class KanbanTasksController < BaseController
      before_action :set_board, only: [:create]
      before_action :set_task, only: [:update, :destroy, :archive, :restore]

      def archived
        tasks = current_user.kanban_tasks
                            .archived
                            .includes(:kanban_board)
                            .order(archived_at: :desc, updated_at: :desc)

        render json: tasks.map { |task| task_json(task, include_board: true) }
      end

      def create
        task = @board.kanban_tasks.build(task_params.except(:position, :kanban_board_id))
        task.position = @board.kanban_tasks.active.maximum(:position).to_i + 1

        if task.save
          render json: task_json(task), status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        return render json: { errors: ['Nao e possivel editar tarefa arquivada.'] }, status: :unprocessable_entity if @task.archived?

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

      def archive
        return render json: { errors: ['Tarefa ja esta arquivada.'] }, status: :unprocessable_entity if @task.archived?

        board = @task.kanban_board

        ActiveRecord::Base.transaction do
          @task.update!(archived_at: Time.current)
          normalize_task_positions!(board)
        end

        render json: task_json(@task.reload, include_board: true)
      end

      def restore
        return render json: { errors: ['Tarefa nao esta arquivada.'] }, status: :unprocessable_entity unless @task.archived?

        target_board = restore_board

        ActiveRecord::Base.transaction do
          @task.kanban_board = target_board
          @task.archived_at = nil
          @task.position = target_board.kanban_tasks.active.maximum(:position).to_i + 1
          @task.save!

          normalize_task_positions!(target_board)
        end

        render json: task_json(@task.reload, include_board: true)
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

        items = board.kanban_tasks.active.where.not(id: task.id)
        max_index = items.count
        desired_index = new_position.to_i
        desired_index = 0 if desired_index.negative?
        desired_index = max_index if desired_index > max_index

        items.order(position: :asc, created_at: :asc).each_with_index do |item, index|
          item.update_column(:position, index >= desired_index ? index + 1 : index)
        end

        task.update_column(:position, desired_index)
      end

      def normalize_task_positions!(board)
        board.kanban_tasks.active.order(position: :asc, created_at: :asc).each_with_index do |task, index|
          task.update_column(:position, index)
        end
      end

      def restore_board
        board_id = params[:kanban_board_id] || params.dig(:kanban_task, :kanban_board_id)
        return @task.kanban_board if board_id.blank?

        current_user.kanban_boards.find(board_id)
      rescue ActiveRecord::RecordNotFound
        @task.kanban_board
      end

      def task_json(task, include_board: false)
        base = {
          id: task.id,
          title: task.title,
          description: task.description,
          position: task.position,
          kanban_board_id: task.kanban_board_id,
          archived_at: task.archived_at,
          created_at: task.created_at,
          updated_at: task.updated_at
        }

        return base unless include_board

        base.merge(
          kanban_board_title: task.kanban_board&.title
        )
      end
    end
  end
end
