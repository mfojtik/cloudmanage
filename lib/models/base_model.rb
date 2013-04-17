module CloudManage::Models
  module BaseModel
    include CloudManage::Workers
    include Helpers::BaseTaskHelper

    def self.included(klass)
      klass.extend(Helpers::BaseTaskHelper::ClassMethods)
    end

  end
end
