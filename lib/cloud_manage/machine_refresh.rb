require_relative '../cloud_manage'

module CloudManage
  class MachineRefresh
    include CloudManage::Models

    def initialize(options = {})
    end

    def run
      Server.all.each do |server|
        next if server.is_deleted?
        next if server.is_new?
        server.background.refresh
      end
    end

  end
end
