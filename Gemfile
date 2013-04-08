source 'https://rubygems.org'

gem 'sinatra', :require => 'sinatra/base'
gem 'sinatra-twitter-bootstrap', ">=2.3.1", :require => 'sinatra/twitter-bootstrap'
gem 'haml'
gem 'colorize'
gem 'rack-flash3', :require => 'rack-flash'
gem 'json_pure', :require => 'json/pure'

gem 'deltacloud-client', :git => 'git://github.com/mifo/deltacloud-client.git'

platforms :jruby do
  gem 'torquebox'
  gem 'torquebox-messaging'
  gem 'torquebox-stomp'
  gem 'torquebox-cache'
  gem 'jdbc-sqlite3'
  gem 'activesupport', '=3.2.13', :require => 'active_support/cache/torque_box_store'
end

platforms :mri do
  gem 'sqlite3'
  gem 'thin'
end

gem 'sequel'
gem 'rest-client'
gem 'json'
gem 'nokogiri'
