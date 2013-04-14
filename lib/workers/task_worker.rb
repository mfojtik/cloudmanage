module CloudManage
  module Workers
    class Retry < StandardError; end
    class TaskWorker
      include Sidekiq::Worker

      sidekiq_options :retry => 5

      def perform(task_id)
        @task = CloudManage::Models::Task[task_id.to_i]
        return if @task.nil?
        return if @task.completed?
        @task.change_state(:pending)
        begin
          @task.klass_ent.send(@task.name, @task.load_params)
          @task.change_state(:complete)
        rescue Retry => e
          @task.change_state(:retry)
          raise(e)
        rescue => e
          @task.change_state(:error, "An error occured while processing Task (#{e.message}##{e.backtrace.first})")
        end
        true
      end

      def retries_exhausted(*args)
        @task.change_state(:error, "Task failed to execute.")
      end

    end
  end
end
