module CloudManage
  module Workers
    module Server

      class ConnectWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 3, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server.ready?
          server.console do |ssh|
            current_stats = ssh.exec!("vmstat | tail -n 1")
          end
        end

      end
    end
  end
end
