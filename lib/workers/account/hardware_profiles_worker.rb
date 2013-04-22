module CloudManage
  module Workers
    module Account

      class HardwareProfilesWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 0, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          account = Models::Account[@task.parse_params['id']]
          counter = 0
          account.log("Populating account hardware profiles")
          profiles = account.client.hardware_profiles
          profiles.each do |profile|
            if current_hwp = account.profile_exists?(profile._id)
              current_hwp.update(:name => profile.name)
            else
              account.add_resource(
                :kind => 'hardware_profile',
                :resource_id => profile._id,
                :name => profile.name
              ) && counter += 1
            end
          end
          @task.change_state(:completed)
          account.log("#{counter} new hardware profiles were imported")
        end

      end
    end
  end
end
