module CloudManage
  module Workers
    module Account

      class RealmsWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 2, :backtrace => 2

        def perform(task_id)
          populate_account_with :realms, task_id
        end

      end
    end
  end
end
