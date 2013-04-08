Bundler.require(:default)

require 'torquebox-messaging'
require_relative './../initializer'

module CloudManage

  class CreateInstanceProcessor < TorqueBox::Messaging::MessageProcessor
    include CloudManage::Models

    def on_message(server_id)
      server = Server[server_id]
      image_id, create_opts = server.image.create_instance_args
      begin
        instance = server.image.account.client.create_instance(image_id, create_opts)
        image.update(:instance_id => instance._id)
      rescue
      end
    end

  end
end
