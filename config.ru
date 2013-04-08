require "bundler/setup"
Bundler.require(:default)

require 'cloud_manage'

require_relative './lib/controllers'
require_relative './lib/app'

use Rack::Reloader
run CloudManage::UI
