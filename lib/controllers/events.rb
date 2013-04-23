module CloudManage::Controllers
  class Events < Base

    get '/events' do
      tasks = Task.order(Sequel.desc(:created_at)).paginate(page, 20)
      haml :'events/index', :locals => { :tasks => tasks }
    end

    get '/tasks/:id' do
      haml :'events/task', :locals => { :task => Task[params['id']] }
    end

  end
end
