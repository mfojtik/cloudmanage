module CloudManage
  module Workers
    module Account

      class InstancesWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 3, :backtrace => 2

        def perform(account_id)
          @account = Models::Account[account_id]
          instances = @account.client.instances
          @account.running_servers.each do |server|
            if inst = instances.find { |i| i._id == server.instance_id }
              server.update(:state => inst.state)
              address = inst.public_addresses.first
              if [:hostname, :ipv4].include?(address.type) and server.address != address.to_s
                server.update_address(address)
              end
            else
              server.update(:state => 'STOPPED')
            end
          end
          InstancesWorker.perform_in(120, account_id)
        end

        def retries_exhausted(worker, msg)
          InstancesWorker.perform_in(180, @account.id)
        end

        private

        def server_instance?(servers, inst_id)
          servers.find { |s| s.instance_id == inst_id }
        end

      end
    end
  end
end
