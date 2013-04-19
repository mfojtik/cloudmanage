module CloudManage
  module Workers

    class ServerRunningWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 5, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        server = Server[@task.parse_params['id']]
        server.log("Waiting for server become RUNNING")
        begin
          instance = server.instance
        rescue => e
          server.log("Error occured while polling for state: #{e.message}", 'ERROR')
          retry_task
        end
        server.update(:state => instance.state)
        if server.state == 'RUNNING'
          server.log("Server changed state to RUNNING")
          @task.change_state(:completed)
          server.task_dispatcher(:server_address_worker)
        elsif server.state == 'STOPPED'
          server.log("Server changed state to STOPPED")
          @task.change_state(:completed)
          server.task_dispatcher(:server_start_worker)
        else
          server.log("Server state is still #{server.state}")
          retry_task
        end
      end

    end
  end
end
