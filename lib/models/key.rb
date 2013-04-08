module CloudManage::Models
  class Key < Sequel::Model

    many_to_one :account
    one_to_many :images

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    def validate
      super
      validates_presence [:username]
    end

    def kind
      return :ssh if password.nil?
      return :ssh if password.empty?
      return :password
    end

    def self.create_with_backend(create_opts={})
      existing_key_id = create_opts.delete('id')
      if existing_key_id
        Key[existing_key_id].update(create_opts)
      else
        key = new(create_opts)
        DB.transaction do
          begin
            backend_key = key.account.client.create_key(key.name.strip, :public_key => key.pem.strip)
            key.update(:backend_id => backend_key._id)
            key.update(:pem => backend_key.pem) if key.pem.strip.empty?
            key.save
          rescue => e
            puts e.message
            raise Sequel::Rollback
          end
        end
        key
      end
    end

  end
end
