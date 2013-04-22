module CloudManage
  module Workers
    module Server

      class RunningWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 5, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server
          server.log("Waiting for server become RUNNING")
          instance = server.instance
          server.update(:state => instance.state)
          if server.state == 'RUNNING'
            server.log("Server changed state to RUNNING")
            @task.change_state(:completed)
            server.task_dispatcher(:address)
          elsif server.state == 'STOPPED'
            server.log("Server changed state to STOPPED")
            @task.change_state(:completed)
            server.task_dispatcher(:start)
          else
            server.log("Server state is still #{server.state}")
            retry_task
          end
        end

      end
    end
  end
end
