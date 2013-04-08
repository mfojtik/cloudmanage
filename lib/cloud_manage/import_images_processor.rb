require_relative '../cloud_manage'

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
            img.add_event(:message => "Image succesfully imported #{img.image_id}")
          rescue => e
            img.add_event(:severity => 'ERROR', :message => "Unable to import image #{img.image_id} (#{e.message})")
          end
        end
      end
    end

  end
end
