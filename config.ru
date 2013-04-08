require "bundler/setup"
Bundler.require(:default)

require './lib/initializer'
require './app'

use Rack::Reloader
run CloudManage::UI
