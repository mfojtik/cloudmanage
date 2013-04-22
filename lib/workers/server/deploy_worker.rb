module CloudManage
  module Workers
    module Server

      class DeployWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 3, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          image_id, create_opts = server.image.create_instance_args
          server.log("Launching the backend instance")
          instance = server.client.create_instance(image_id, create_opts)
          if server.update(:state => instance.state, :instance_id => instance._id)
            server.log("Backend instance successfully launched (#{instance._id})")
            @task.change_state(:completed)
            if server.state == 'RUNNING'
              server.task_dispatcher(:address)
            else
              server.task_dispatcher(:running)
            end
          end
        end

      end
    end
  end
end
