module CloudManage
  module Workers
    module Server

      class DestroyWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 5, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server
          instance = server.instance
          server.update(:state => instance.state)
          if instance.actions.include?(:destroy)
            retry_task unless server.client.destroy_instance(server.instance_id)
            server.destroy
          elsif instance.actions.include?(:stop)
            server.task_dispatcher(:stop)
          else
            retry_task
          end
          @task.change_state(:completed)
        end

      end
    end
  end
end
