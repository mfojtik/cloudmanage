module CloudManage::Workers::Helpers
  module AccountTasksHelper

    def import_images_task!
      task.run(:image, :import, :account_id => self.id)
    end

  end
end
