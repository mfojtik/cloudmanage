Bundler.require(:default)

require 'torquebox-messaging'
require_relative './../initializer'

module CloudManage

  class CreateInstanceProcessor < TorqueBox::Messaging::MessageProcessor
    include CloudManage::Models

    def on_message(server_id)
      server = Server[server_id]
      if instance = create_backend_instance_from(server)
        server.update(:instance_id => instance._id, :state => instance.state)
        server.add_event(:message => "Machine successfully created")
      end
    end

    private

    def create_backend_instance_from(server)
      begin
        image_id, create_opts = server.image.create_instance_args
        server.image.account.client.create_instance(image_id, create_opts)
      rescue => e
        server.add_event(:severity => 'ERROR', :message => "Unable to create server (#{e.message})")
        server.set_deleted!
        false
      end
    end

  end
end
