module CloudManage
  module Workers
    module Account

      class FirewallsWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 0, :backtrace => 2

        def perform(task_id)
          populate_account_with :firewalls, task_id
        end

      end
    end
  end
end
