module CloudManage
  module Workers

    class ServerDestroyWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 5, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        server = Server[@task.parse_params['id']]
        begin
          instance = server.instance
        rescue => e
          if server
            server.log("Error occured while performing start: #{e.message}", 'ERROR')
            retry_task
          end
        end
        return if server.nil?
        server.update(:state => instance.state)
        if instance.actions.include?(:destroy)
          if server.client.destroy_instance(server.instance_id)
            server.destroy
            @task.change_state(:completed)
          else
            retry_task
          end
        elsif instance.actions.include?(:stop)
          server.task_dispatcher(:server_stop_worker)
          @task.change_state(:completed)
        else
          retry_task
        end
      end

    end
  end
end
