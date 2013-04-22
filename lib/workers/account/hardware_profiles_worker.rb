module CloudManage
  module Workers
    module Account

      class HardwareProfilesWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 0, :backtrace => 2

        def perform(task_id)
          populate_account_with :hardware_profiles, task_id
        end

      end
    end
  end
end
