module CloudManage
  module Workers

    class DeployServerWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 3, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        server = Server[@task.parse_params['id']]
        image_id, create_opts = server.image.create_instance_args
        server.log("Starting deployment")
        begin
          instance = server.client.create_instance(image_id, create_opts)
        rescue => e
          @task.change_state(:error, "Unable to create backend instance (#{e.message})")
          retry_task
        end
        if server.update(:state => instance.state, :instance_id => instance._id)
          server.log("Server successfully deployed")
          @task.change_state(:completed)
          if server.state == 'RUNNING'
            server.task_dispatcher(:server_address_worker)
          else
            server.task_dispatcher(:server_running_worker)
          end
        end
      end

    end
  end
end
