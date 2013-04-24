module CloudManage::Models
  class Recipe < Sequel::Model

    plugin :timestamps, :create => :created_at, :update => :updated_at
    many_to_many :servers

  end
end
