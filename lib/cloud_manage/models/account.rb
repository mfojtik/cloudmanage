module CloudManage::Models
  class Account < Sequel::Model

    one_to_many :images
    one_to_many :keys
    one_to_many :events

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    plugin :association_dependencies,
      :images => :destroy,
      :keys => :delete,
      :events => :delete

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
      self.client.hardware_profiles.map { |h| { h._id => h.name} }
    end

    def realms
      self.client.realms.map { |r| { r._id => r.name }}
    end

    def firewalls
      self.client.firewalls.map { |f| { f._id => f.name }}
    end

    def create_backend_key(local_key)
      key = client.create_key(local_key.name.strip, :public_key => local_key.pem.strip)
      local_key.update(:backend_id => key._id)
      local_key.update(:pem => key.pem) if local_key.pem.empty?
    end

  end
end
