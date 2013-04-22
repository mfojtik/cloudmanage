module CloudManage::Models
  class Account < Sequel::Model

    include BaseModel

    one_to_many :images
    one_to_many :keys
    one_to_many :events
    one_to_many :resources

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    plugin :association_dependencies,
      :images => :destroy,
      :keys => :delete,
      :events => :delete

    self.use_transactions=false

    def validate
      super
      validates_presence [:name, :driver, :username, :password]
    end

    def api_provider_url
      new? ? nil : (provider_url && provider_url.empty?) ? nil : provider_url
    end

    def client
      @client ||= Deltacloud::Client(
        DELTACLOUD_URL, username, password,
        :driver => driver,
        :provider => api_provider_url
      )
    end

    def image_exists?(image_id)
      images_dataset.where(:image_id => image_id).first
    end

    def realm_exists?(realm_id)
      resource_exists?(:realm, realm_id)
    end

    def hardware_profile_exists?(profile_id)
      resource_exists?(:hardware_profile, profile_id)
    end

    def firewall_exists?(firewall_id)
      resource_exists?(:firewall, firewall_id)
    end

    def resource_exists?(kind, res_id)
      resources_dataset.where(
        :kind => kind.to_s,
        :resource_id => res_id
      ).first
    end

    def get_resources(kind)
      resources_dataset.where(:kind => kind.to_s).map { |r| { r.resource_id => r.name } }
    end

    def drivers
      self.client.drivers.inject([]) { |r,d| r << { d._id => d.name}; r }
    end

    def hardware_profiles
      get_resources(:hardware_profile)
    end

    def realms
      get_resources(:realm)
    end

    def firewalls
      get_resources(:firewall)
    end

    def create_backend_key(local_key)
      key = client.create_key(local_key.name.strip, :public_key => local_key.pem.strip)
      local_key.update(:backend_id => key._id)
      local_key.update(:pem => key.pem) if local_key.pem.empty?
    end

    def running_servers
      images.map { |i| i.servers_dataset.where(:state => 'RUNNING').all }.flatten
    end

    def populate_servers(t=120)
      CloudManage::Workers::Account::InstancesWorker.perform_in(t, self.id)
    end

    def self.refresh_servers!
      all.each_with_index { |a, i| a.populate_servers(120 + (i*5)) }
    end

    def after_create
      super
      task_dispatcher(:images)
      task_dispatcher(:realms)
      task_dispatcher(:hardware_profiles)
      task_dispatcher(:firewalls) if client.support?(:firewalls)
      populate_servers
    end

  end
end
