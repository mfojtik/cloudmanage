module CloudManage
  module Workers
    module Server

      class AddressWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 5, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server
          server.log("Waiting for server to receive IP address")
          instance = server.instance
          address = instance.public_addresses.first
          if [:hostname, :ipv4].include?(address.type)
            server.update_address(address)
            @task.change_state(:completed)
            server.task_dispatcher(:recipe)
          else
            server.log("Server does not receive IP address yet")
            retry_task
          end
        end

      end
    end
  end
end
