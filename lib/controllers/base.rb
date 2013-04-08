module CloudManage::Controllers

  class Base < Sinatra::Base
    register Sinatra::Twitter::Bootstrap::Assets

    include CloudManage::Models
    helpers CloudManage::ApplicationHelper
    helpers CloudManage::HamlHelper
    include TorqueBox::Injectors if RUBY_PLATFORM == 'java'

    set :views, File.join(File.dirname(__FILE__), '..', '..', 'views')
  end

end
