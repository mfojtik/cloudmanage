module CloudManage::Models
  class Resource < Sequel::Model

    include BaseModel
    many_to_one :account

  end
end
