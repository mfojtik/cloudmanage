Bundler.require(:default)

require 'torquebox-messaging'
require_relative './../initializer'

module CloudManage

  class ImportImagesProcessor < TorqueBox::Messaging::MessageProcessor
    include CloudManage::Models

    def on_message(account_id)
      account = Account[account_id]
      return unless account
      account.client.images.each do |img|
        img = Image.new(
          :account_id => account.id,
          :image_id => img._id,
          :name => img.name,
          :description => img.description
        )
        if img.valid?
          begin
            img.save
          rescue => e
            CloudManage.logger.error "#{img.id} could not be saved #{e.message}"
          end
        end
      end
    end

  end
end
