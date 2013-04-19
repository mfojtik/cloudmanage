module CloudManage
  module Workers

    class PopulateRealmsWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 0, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        account = Account[@task.parse_params['id']]
        counter = 0
        account.log("Populating account realms")
        begin
          realms = account.client.realms
        rescue => e
          @task.change_state(:error, "Error fetching realms (#{e.message})")
          return
        end
        realms.each do |realm|
          if current_realm = account.realm_exists?(realm._id)
            current_realm.update(:name => realm.name)
          else
            account.add_resource(
              :kind => 'realm',
              :resource_id => realm._id,
              :name => realm.name
            ) && counter += 1
          end
        end
        @task.change_state(:completed)
        account.log("#{counter} new realms were imported")
      end

    end
  end
end
