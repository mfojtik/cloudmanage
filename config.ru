$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'cloud_manage'
require 'controllers'
require 'app'

run CloudManage::UI
