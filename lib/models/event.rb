module CloudManage::Models
  class Event < Sequel::Model

    plugin :timestamps, :create => :created_at
    many_to_one :account
    many_to_one :key
    many_to_one :server
    many_to_one :image

    def kind
      return :server if self.server_id
      return :account if self.account_id
      return :image if self.image_id
      return :key if self.key_id
      :none
    end

  end
end
