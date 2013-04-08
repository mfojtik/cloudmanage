module CloudManage::Controllers
  class Events < Base

    get '/events' do
      events = Event.dataset.order(Sequel.desc(:created_at)).paginate((params[:page] ? params[:page].to_i : 1), 50)
      haml :'events/index', :locals => { :events => events }
    end
  end
end
