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
          return unless server
          return unless server.ready?
          server.console do |ssh|
            server.recipes.each do |recipe|
              ssh.open_channel do |channel|
                channel.exec("dd of=recipe_#{recipe.id}.sh") do |ch, success|
                  channel.send_data "#{recipe.sanitized_body}\n"
                  channel.eof!
                  server.log("Recipe successfully uploaded: #{recipe.name}")
                end
              end
            end
            ssh.open_channel do |channel|
              channel.exec("dd of=run.sh") do |ch, success|
                channel.send_data "#{runner_script(server.recipes.map { |r| r.id })}\n"
                channel.eof!
              end
            end
            ssh.loop
          end
          @task.change_state :completed
          server.task_dispatcher(:run_recipe)
        end

        def runner_script(ids_arr)
          script = ['#!/bin/bash']
          ids_arr.each do |recipe_id|
            script << "sh recipe_#{recipe_id}.sh"
          end
          script.join("\n")
        end

      end
    end
  end
end
