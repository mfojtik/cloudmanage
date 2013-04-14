module CloudManage::Models
  class Server < Sequel::Model

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    many_to_one :image
    one_to_many :events

    plugin :association_dependencies,
      :events => :delete

    def update_address(new_address)
      if self.address != new_address
        update(:address => new_address)
        add_event(:message => "IP address changed to #{self.address}")
      end
    end

    def client
      @client ||= self.image.account.client
    end

    #### sidekiq methods ####
    #
    def task
      CloudManage::Models::Task
    end

    def wait_for_running_task!
      task.run(:server, :wait_for_running, :server_id => self.id)
    end

    def wait_for_address_task!
      task.run(:server, :wait_for_address, :server_id => self.id)
    end

    def self.deploy(opts={})
      srv = Server[opts['server_id']]
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

    def self.wait_for_running(opts={})
      srv = Server[opts['server_id']]
      inst = srv.client.instance(srv.instance_id)
      srv.add_event(:message => "Waiting for server to become RUNNING")
      srv.update(:state => inst.state) if inst.state != srv.state
      unless srv.state == 'RUNNING'
        raise CloudManage::Workers::Retry
      else
        srv.wait_for_address_task!
      end
    end

    def self.wait_for_address(opts={})
      srv = Server[opts['server_id']]
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
end
