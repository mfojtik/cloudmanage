module CloudManage::Models
  class Metric < Sequel::Model

    self.use_transactions=false

    plugin :timestamps, :create => :created_at
    many_to_one :server

  end
end
