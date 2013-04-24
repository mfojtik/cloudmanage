module CloudManage
  module Workers
    module Server

      class RunRecipeWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 0, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server.ready?
          server.console do |ssh|
            ssh.open_channel do |channel|
              channel.request_pty do |c, success|
                c.exec("sh run.sh") if success
              end
            end
            ssh.loop
          end
          @task.change_state :completed
        end

      end
    end
  end
end
