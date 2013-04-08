module CloudManage::Models
  class Event < Sequel::Model
    plugin :timestamps, :create => :created_at
    many_to_one :account
    many_to_one :key
    many_to_one :server
    many_to_one :image

  end
end
