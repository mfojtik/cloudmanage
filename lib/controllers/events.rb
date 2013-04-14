module CloudManage::Controllers
  class Events < Base

    get '/events' do
      puts page
      events = Event.order(Sequel.desc(:created_at)).paginate(page, 20)
      tasks = Task.order(Sequel.desc(:created_at)).paginate(page, 20)
      haml :'events/index', :locals => { :events => events, :tasks => tasks }
    end
  end
end
