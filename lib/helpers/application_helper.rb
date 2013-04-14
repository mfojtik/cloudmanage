module CloudManage
  module ApplicationHelper

    def report_error_for(model)
      errors = model.errors.inject("") { |r, err|
        r+="<em>#{err[0]}</em>: #{err[1].join(' and ')}<br/>"
      }
      flash[:error] = errors
      redirect(back) && halt
    end

    def page
      params['page'] ? params['page'].to_i : 1
    end

  end
end
