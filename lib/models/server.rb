module CloudManage::Models
  class Server < Sequel::Model

    include BaseModel
    include Helpers::ServerTasksHelper

    plugin :timestamps,
      :create => :created_at, :update => :updated_at

    many_to_one :image
    one_to_many :events

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

  end
end
