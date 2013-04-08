require_relative './lib/initializer'
require 'haml'
require 'active_support/cache/torque_box_store'

module CloudManage
  class UI < Sinatra::Base
    register Sinatra::Twitter::Bootstrap::Assets

    #enable :sessions
    use TorqueBox::Session::ServletStore
    use Rack::Flash

    set :cache, ActiveSupport::Cache::TorqueBoxStore.new

    use CloudManage::Controllers::Accounts
    use CloudManage::Controllers::Images
    use CloudManage::Controllers::Keys
    use CloudManage::Controllers::Servers

    get '/' do
      redirect url("/accounts")
    end

  end
end
