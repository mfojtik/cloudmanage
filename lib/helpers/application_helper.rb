module CloudManage
  module ApplicationHelper

    def report_error_for(model)
      errors = model.errors.inject("") { |r, err|
        r+="<em>#{err[0]}</em>: #{err[1].join(' and ')}<br/>"
      }
      report_error(errors)
    end

    def report_error(message)
      flash[:error] = message
      redirect(back) && halt
    end

    def page
      params['page'] ? params['page'].to_i : 1
    end

  end
end
