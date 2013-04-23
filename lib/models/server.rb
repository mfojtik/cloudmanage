module CloudManage::Models
  class Server < Sequel::Model

    include BaseModel
    include CloudManage::Workers::TaskHelper

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    many_to_one :image
    one_to_many :events
    one_to_many :metrics

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

    def instance
      begin
        client.instance(instance_id)
      rescue
        retry_task
      end
    end

    def ready?
      (state == 'RUNNING') && (!address.nil?)
    end

    def console(&block)
      Net::SSH.start(address, image.key.username, console_opts) do |ssh|
        yield(ssh)
      end
    end

    def private_key
      image.key.pem.each_line.map { |l| l.strip }.join("\n")
    end

    def console_opts
      return { :password => image.key.password } if image.key.kind == :password
      if image.key.kind == :ssh_public
        key_filename = File.join('/', 'tmp', "server_#{self.id}.key")
        File.open(key_filename, "w", 0600) { |f| f.write(image.key.pem) }
        return { :keys => [key_filename], :keys_only => true }
      end
      if image.key.kind == :ssh_private
        return { :key_data => [private_key], :keys_only => true }
      end
    end

  end
end
