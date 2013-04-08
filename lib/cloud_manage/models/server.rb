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

    def set_deleted!
      update(:state => 'deleted')
      add_event(:message => "The server has been removed on backend.")
    end

    def is_deleted?
      state == 'deleted'
    end

    def is_new?
      state == 'new'
    end

    def sync_attributes
      instance = get_backend_instance
      return false unless instance
      if !instance.public_addresses.empty?
        if acceptable_address_type?(instance.public_addresses.first)
          update(:address => instance.public_addresses.first.value)
          server.add_event(:message => "IP address changed to #{instance.address}")
        end
      end
      if server.state != instance.state
        server.add_event(:message => "State changed from #{server.state} to #{instance.state}")
        update(:state => instance.state)
      end
      server
    end

    private

    def get_backend_instance
      begin
        self.image.account.client.instance(server.instance_id)
      rescue Deltacloud::Client::NotFound
        self.set_deleted!
        false
      rescue => e
        add_event(:severity => 'ERROR', :message => "Unable to retrieve server details (#{e.message})")
        false
      end
    end

    def acceptable_address_type?(address)
      ['hostname', 'ipv4'].include? address.type.to_s
    end

  end
end
