module CloudManage
  module Workers
    module Account

      class RealmsWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 2, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          account = Models::Account[@task.parse_params['id']]
          counter = 0
          account.log("Populating account realms")
          realms = account.client.realms
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
end
