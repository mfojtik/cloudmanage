require 'will_paginate/sequel'

module CloudManage::Controllers

  class Base < Sinatra::Base
    register Sinatra::Twitter::Bootstrap::Assets
    register WillPaginate::Sinatra

    include CloudManage::Models

    helpers CloudManage::ApplicationHelper
    helpers CloudManage::HamlHelper
    disable :show_exceptions

    error Sequel::ValidationFailed do
      report_error_for(env['sinatra.error'].model)
      redirect(back) && halt
    end

    set :views, File.join(File.dirname(__FILE__), '..', '..', 'views')
  end

end
