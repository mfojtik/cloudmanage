module CloudManage::Workers::Helpers
  module ServerTasksHelper

    def wait_for_running_task!
      on_background :wait_for_running, :server_id => self.id
    end

    def wait_for_address_task!
      on_background :wait_for_address, :server_id => self.id
    end

    module ClassMethods

      def deploy(opts={})
        srv = CloudManage::Models::Server[opts['server_id']]
        image_id, create_opts = srv.image.create_instance_args
        inst = srv.client.create_instance(image_id, create_opts)
        srv.update(:state => inst.state, :instance_id => inst._id)
        srv.add_event(:message => "Server succesfully started #(#{inst._id})")
        unless srv.state == 'RUNNING'
          srv.wait_for_running_task!
        else
          srv.wait_for_address_task!
        end
      end

      def remove(opts={})
        srv = CloudManage::Models::Server[opts['server_id']]
        begin
          inst = srv.client.instance(srv.instance_id)
          srv.update(:state => inst.state)
        rescue Deltacloud::Client::NotFound
          srv.destroy
          return true
        end
        if inst.actions.include?(:destroy) && srv.client.destroy_instance(inst._id)
          srv.destroy
          return true
        else
          if inst.actions.include?(:stop) && srv.client.stop_instance(inst._id)
            srv.add_event(:message => "Waiting for instance to STOP")
          else
            srv.add_event(
              :severity => 'ERROR',
              :message => "Unable to determine how to destroy this server."
            )
          end
        end
        raise CloudManage::Workers::Retry
      end

      def wait_for_running(opts={})
        srv = CloudManage::Models::Server[opts['server_id']]
        inst = srv.client.instance(srv.instance_id)
        srv.add_event(:message => "Waiting for server to become RUNNING")
        srv.update(:state => inst.state) if inst.state != srv.state
        unless srv.state == 'RUNNING'
          raise CloudManage::Workers::Retry
        else
          srv.wait_for_address_task!
        end
      end

      def wait_for_address(opts={})
        srv = CloudManage::Models::Server[opts['server_id']]
        inst = srv.client.instance(srv.instance_id)
        srv.add_event(:message => "Waiting for server IP address")
        raise CloudManage::Workers::Retry if inst.public_addresses.empty?
        addr = inst.public_addresses.first
        if [:hostname, :ipv4].include?(addr.type)
          srv.update_address(addr)
        else
          raise CloudManage::Workers::Retry
        end
      end

    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

  end
end
