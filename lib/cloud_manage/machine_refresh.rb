Bundler.require(:default)

require 'torquebox-messaging'
require_relative './../initializer'

module CloudManage
  class MachineRefresh
    include CloudManage::Models

    def initialize(options = {})
    end

    def run
      Server.all.each do |server|
        next if server.is_deleted?
        next if server.is_new?
        server.background.sync_attributes
      end
    end

  end
end
