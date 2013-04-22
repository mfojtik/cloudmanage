$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'cloud_manage'
require 'controllers'
require 'app'
require 'sidekiq/web'

# We need to run this task here, otherwise sidekiq will duplicate it
#
Sidekiq::ScheduledSet.new.clear
CloudManage::Models::Account.refresh_servers!

Deltacloud::configure do |server|
  server.root_url '/api'
  server.version '1.1.3'
  server.klass 'Deltacloud::API'
end

Deltacloud[:deltacloud].require!(:mock_initialize => true)

app = Rack::Builder.new {
  map '/api' do
    run Deltacloud::API
  end
  map '/sidekiq' do
    run Sidekiq::Web
  end
  map '/' do
    run CloudManage::UI
  end
}

run app
