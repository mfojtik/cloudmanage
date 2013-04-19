module CloudManage::Models
  class Resource < Sequel::Model

    include BaseModel

    many_to_one :account

    def self.populate_realms(opts={})
      account = Account[opts['account_id']]

    end

    def self.populate_hwp(opts={})
      account = Account[opts['account_id']]
      counter = 0
      account.add_event(:message => "Populating hardware profiles")
      account.client.hardware_profiles.each do |hwp|
        if saved_hwp = account.resources_dataset.where(:kind => 'hardware_profile', :resource_id => hwp._id).first
          saved_hwp.update(:name => hwp.name)
        else
          account.add_resource(:kind => 'hardware_profiles', :resource_id => hwp._id, :name => hwp.name)
          counter += 1
        end
      end
      account.add_event(:message => "#{counter} hardware profiles imported")
    end

  end
end
