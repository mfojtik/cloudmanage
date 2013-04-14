module CloudManage
  module Controllers
    require_relative './helpers/application_helper'
    require_relative './helpers/haml_helper'
    require_relative './controllers/base'
    require_relative './controllers/accounts'
    require_relative './controllers/images'
    require_relative './controllers/keys'
    require_relative './controllers/servers'
    require_relative './controllers/events'
  end
end
