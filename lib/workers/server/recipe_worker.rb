module CloudManage
  module Workers
    module Server

      class RecipeWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 5, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          server = Models::Server[@task.parse_params['id']]
          return unless server.ready?
          server.recipes.each do |recipe|
            Net::SCP.upload!(
              server.address, server.image.key.username,
              StringIO.new(recipe.body), "/#{server.image.key.username}/recipe_#{recipe.id}.sh",
              server.console_opts
            )
            server.log("#{recipe.name} uploaded")
          end
          @task.change_state :completed
        end

      end
    end
  end
end
