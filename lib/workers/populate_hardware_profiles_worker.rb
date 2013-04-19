module CloudManage
  module Workers

    class PopulateHardwareProfilesWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 0, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        account = Account[@task.parse_params['id']]
        counter = 0
        account.log("Populating account hardware profiles")
        begin
          profiles = account.client.hardware_profiles
        rescue => e
          @task.change_state(:error, "Error fetching hardware profiles (#{e.message})")
          return
        end
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
