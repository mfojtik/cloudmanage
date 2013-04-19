module CloudManage
  module Workers

    class ServerStopWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 5, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        server = Server[@task.parse_params['id']]
        begin
          if server.client.stop_instance(server.instance_id)
            server.update(:state => server.instance.state)
            server.log("Successfully stopped the server")
            server.task_dispatcher(:server_destroy_worker)
            @task.change_state(:completed)
          else
            retry_task
          end
        rescue => e
          server.log("Error occured while performing stop: #{e.message}", 'ERROR')
          retry_task
        end
      end

    end
  end
end
