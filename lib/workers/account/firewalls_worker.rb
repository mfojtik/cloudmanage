module CloudManage
  module Workers
    module Account

      class FirewallsWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 0, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          account = Models::Account[@task.parse_params['id']]
          counter = 0
          account.log("Populating account firewalls")
          firewalls = account.client.firewalls
          firewalls.each do |firewall|
            if current_firewall = account.firewall_exists?(firewall._id)
              current_firewall.update(:name => firewall.name)
            else
              account.add_resource(
                :kind => 'firewall',
                :resource_id => firewall._id,
                :name => firewall.name
              ) && counter += 1
            end
          end
          @task.change_state(:completed)
          account.log("#{counter} new firewalls were imported")
        end

      end
    end
  end
end
