module CloudManage
  class UI < Sinatra::Base

    configure :development do
      Sinatra::Application.reset!
      use Rack::Reloader
      #use Rack::CommonLogger
    end

    register Sinatra::Twitter::Bootstrap::Assets

    enable :sessions
    set :public_folder, File.join(File.dirname(__FILE__), '../public')

    use Rack::Flash
    use CloudManage::Controllers::Accounts
    use CloudManage::Controllers::Images
    use CloudManage::Controllers::Keys
    use CloudManage::Controllers::Servers
    use CloudManage::Controllers::Events

    get '/' do
      redirect url("/accounts")
    end

  end
end
