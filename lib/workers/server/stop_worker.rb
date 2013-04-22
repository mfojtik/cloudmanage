module CloudManage
  module Workers
    module Server

      class StopWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 5, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server
          begin
            retry_task unless server.client.stop_instance(server.instance_id)
          rescue => e
            server.log("Unable to stop server: #{e.message}")
            retry_task
          end
          server.update(:state => server.instance.state)
          server.log("Successfully stopped the server")
          server.task_dispatcher(:destroy)
          @task.change_state(:completed)
        end

      end
    end
  end
end
