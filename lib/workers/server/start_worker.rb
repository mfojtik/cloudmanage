module CloudManage
  module Workers
    module Server

      class StartWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 5, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server
          begin
            retry_task unless server.client.start_instance(server.instance_id)
          rescue => e
            server.log("Unable to start server: #{e.message}")
            retry_task
          end
          server.update(:state => server.instance.state)
          server.log("Server started successfully")
          server.task_dispatcher(:running)
          @task.change_state(:completed)
        end

      end
    end
  end
end
