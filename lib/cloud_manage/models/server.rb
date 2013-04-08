module CloudManage::Models
  class Server < Sequel::Model
    include TorqueBox::Messaging::Backgroundable

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    many_to_one :image
    one_to_many :events

    def self.create_from_image(image_id)
      server = Server.new(:image_id => image_id)
      TorqueBox::Messaging::Queue.new('/queues/create_instance').publish(server.id) if server.save
      server
    end

    def queue_destroy!
      TorqueBox::Messaging::Queue.new('/queues/destroy_instance').publish(self.id)
    end

    def set_deleted!
      update(:state => 'deleted')
      add_event(:message => "The server has been removed on backend.")
    end

    def set_error!(e)
      update(:state => 'error')
      msg = e.kind_of?(Exception) ? e.message : e
      add_event(:message => "An error occured while processing this server (#{msg})")
    end

    def is_deleted?
      state == 'deleted'
    end

    def is_error?
      state == 'error'
    end

    def is_new?
      state == 'new'
    end

    def update_address(new_address)
      if self.address != new_address
        update(:address => new_address)
        add_event(:message => "IP address changed to #{self.address}")
      end
    end

    def refresh
      instance = get_backend_instance
      return false unless instance
      if !instance.public_addresses.empty?
        if acceptable_address_type?(instance.public_addresses.first)
          update_address(instance.public_addresses.first.value)
        end
      end
      if self.state != instance.state
        add_event(:message => "State changed from #{self.state} to #{instance.state}")
        update(:state => instance.state)
      end
      self
    end

    def get_backend_instance
      begin
        self.image.account.client.instance(self.instance_id)
      rescue Deltacloud::Client::NotFound
        self.set_deleted!
        false
      rescue => e
        self.set_error!(e)
        false
      end
    end

    def acceptable_address_type?(address)
      ['hostname', 'ipv4'].include? address.type.to_s
    end

    def stopwait
      retries = 5
      begin
        if instance = get_backend_instance
          if instance.state == 'STOPPED'
            add_event("Server is now stopped")
            update(:state => 'STOPPED')
            TorqueBox::Messaging::Queue.new('/queues/destroy_instance').publish(self.id)
          else
            raise
          end
        else
          set_deleted!
        end
      rescue
        retries -= 1
        add_event(:message => "Waiting for server to stop. ##{retries}")
        sleep(10)
        retry if retries >= 0
      end
    end

  end
end
