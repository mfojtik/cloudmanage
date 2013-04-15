module CloudManage::Models
  class Image < Sequel::Model

    many_to_one :account
    many_to_one :key
    one_to_many :servers
    one_to_many :events

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    plugin :association_dependencies,
      :servers => :destroy,
      :events => :delete

    def validate
      super
      validates_presence [:name, :account_id, :image_id]
    end

    def starred?
      starred == 't'
    end

    def ready_for_launch?
      !key_id.nil?
    end

    def create_instance_args
      create_args = []
      create_args << image_id
      create_opts = {}
      create_opts[:keyname] = self.key.backend_id
      create_opts[:realm_id] = realm_id unless realm_id.to_s.empty?
      create_opts[:hwp_id] = hwp_id unless hwp_id.to_s.empty?
      create_opts[:hwp_cpu] = hwp_id unless hwp_cpu.to_s.empty?
      create_opts[:hwp_memory] = hwp_memory unless hwp_memory.to_s.empty?
      create_opts[:hwp_storage] = hwp_storage unless hwp_storage.to_s.empty?
      create_opts[:firewall0] = firewall_id unless firewall_id.to_s.empty?
      create_args << create_opts
    end

    #### sidekiq methods ####
    #
    def task
      CloudManage::Models::Task
    end

    def self.import(opts={})
      acc = Account[opts['account_id']]
      acc.client.images.each do |img|
        img = Image.new(
          :account_id => acc.id,
          :image_id => img._id,
          :name => img.name,
          :description => img.description
        )
        begin
          img.save if img.valid?
        rescue => e
          img.add_event(:severity => 'ERROR', :message => "Unable to import image #{img.image_id} (#{e.message})")
        end
      end
    end

  end
end
