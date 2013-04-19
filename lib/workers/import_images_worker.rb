module CloudManage
  module Workers

    class ImportImagesWorker

      include Sidekiq::Worker
      include CloudManage::Workers::TaskHelper
      include CloudManage::Models

      sidekiq_options :retry => 0, :backtrace => 2

      def perform(task_id)
        return unless setup_task(task_id)
        account = Account[@task.parse_params['id']]
        account.log('Populating account images')
        begin
          images = account.client.images
        rescue => e
          @task.change_state(:error, "Error fetching images (#{e.message})")
          return
        end
        counter = 0
        images.each do |img|
          begin
            next if account.image_exists?(img._id)
            account.add_image(
              :image_id => img._id,
              :name => img.name,
              :description => img.description
            ) && counter+=1
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
