module CloudManage::Models
  class Server < Sequel::Model

    many_to_one :image

    def self.create_from_image(image_id)
      server = Server.new(:image_id => image_id)
      server.save
    end

  end
end
