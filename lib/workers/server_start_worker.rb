module CloudManage
  module Workers

    class ServerStartWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 5, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        server = Server[@task.parse_params['id']]
        begin
          if server.client.start_instance(server.instance_id)
            server.update(:state => server.instance.state)
            server.log("Successfully started the server")
            server.task_dispatcher(:server_running_worker)
            @task.change_state(:completed)
          else
            retry_task
          end
        rescue => e
          server.log("Error occured while performing start: #{e.message}", 'ERROR')
          retry_task
        end
      end

    end
  end
end
