module CloudManage::Models
  class Account < Sequel::Model

    one_to_many :images
    one_to_many :keys

    DELTACLOUD_URL = 'http://localhost:3001/api'

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    def validate
      super
      validates_presence [:name, :driver, :username, :password]
    end

    def api_provider_url
      new? ? nil : (provider_url && provider_url.empty?) ? nil : provider_url
    end

    def client
      Deltacloud::Client(
        DELTACLOUD_URL, username, password,
        :driver => driver,
        :provider => api_provider_url
      )
    end

    def drivers
      self.client.drivers.inject([]) { |r,d| r << { d._id => d.name}; r }
    end

    def hardware_profiles
      cache(:hardware_profiles, Proc.new { self.client.hardware_profiles })
    end

    def realms
      cache(:realms, Proc.new { self.client.realms })
    end

    def firewalls
      self.client.firewalls.map { |f| { f._id => f.name }}
    end

    def can_create_keys?
      self.client.support?('keys') and self.client.feature?(:instances, :authentication_key)
    end

    def create_backend_key(local_key)
      key = client.create_key(local_key.name.strip, :public_key => local_key.pem.strip)
      local_key.update(:backend_id => key._id)
      local_key.update(:pem => key.pem) if local_key.pem.empty?
    end

    def import_images!
      TorqueBox::Messaging::Queue.new('/queues/import_images').publish(self.id)
    end

    def cache(name, collection_proc)
      cache_key = "#{self.id}_#{name}"
      if cache_provider.contains_key? cache_key
        JSON::parse(cache_provider.get(cache_key))
      else
        elements = collection_proc.call.map { |ent| { ent._id => ent.name} }
        cache_provider.put("#{self.id}_#{name}", elements.to_json)
        elements
      end
    end

    def cache_provider
      @cache_provider ||= TorqueBox::Infinispan::Cache.new(:name => 'cloudmanage', :persist => '/data/cloudmanage')
    end

  end
end
