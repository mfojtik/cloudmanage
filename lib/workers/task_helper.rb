module CloudManage
  module Workers
    module TaskHelper

      class Retry < StandardError
        def backtrace; []; end
      end

      def setup_task(task_id)
        @task = CloudManage::Models::Task[task_id]
        return false if task_is_nil?(task_id)
        return false if @task.completed?
        if @task.state == 'PENDING'
          true
        else
          @task.change_state(:pending)
        end
      end

      def task_is_nil?(task_id)
        if @task.nil?
          CloudManage::Models::Event.create(:severity => 'ERROR', :message => "Task does not exists #{task_id}")
          return true
        end
      end

      def retry_task
        raise Retry
      end

    end
  end
end
