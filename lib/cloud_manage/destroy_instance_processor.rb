require_relative '../cloud_manage'

module CloudManage

  class DestroyInstanceProcessor < TorqueBox::Messaging::MessageProcessor
    include CloudManage::Models

    def on_message(server_id)
      server = Server[server_id]
      if destroy_backend_instance(server)
        Event.create(:message => "Machine successfully destroyed")
      else
        server.add_event(:severity => 'ERROR', :message => "Unable to destroy server")
      end
    end

    private

    def stop_backend_instance(server)
      if server.state == 'RUNNING'
        begin
          if server.image.account.client.stop_instance(server.instance_id)
            server.add_event(:message => "Server successfully stopped")
          else
            server.add_event(:message => "Unable to stop the server #{server.instance_id}")
          end
          server.background.refresh
        rescue => e
          server.add_event(:severity => 'ERROR', :message => "Unable to stop server #{e.message}")
          false
        end
      else
        false
      end
    end

    def destroy_backend_instance(server)
      if instance = server.get_backend_instance
        begin
          if server.state == 'STOPPED' or instance.actions.include?(:destroy)
            destroy_instance(server, instance)
          else
            stop_backend_instance(server)
            server.background.stopwait
            false
          end
        rescue => e
          server.set_error!(e)
          false
        end
      else
        server.set_deleted!
        true
      end
    end

    def destroy_instance(server, instance)
      if instance.destroy!
        server.add_event(:message => 'Backend machine for server successfully destroyed')
        server.destroy
        Event.create(:message => "Server #{server.image.name} successfully destroyed")
        true
      else
        server.set_error!("Unable to destroy backend machine")
      end
    end

  end
end
