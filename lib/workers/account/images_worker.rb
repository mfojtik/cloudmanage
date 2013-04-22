module CloudManage
  module Workers
    module Account

      class ImagesWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 0, :backtrace => 2

        def perform(task_id)
          return unless setup_task(task_id)
          account = Models::Account[@task.parse_params['id']]
          images = account.client.images
          counter = 0
          images.each do |img|
            begin
              account.add_image(
                :image_id => img._id,
                :name => img.name,
                :description => img.description
              ) unless account.image_exists?(img._id)
              counter+=1
            rescue => e
              account.log("Cannot import #{img.image_id} (#{e.message})")
            end
          end
          @task.change_state(:completed)
          account.log("#{counter} new images were imported")
        end

      end
    end
  end
end
