module CloudManage::Controllers
  class Servers < Base

    get '/servers' do
      servers = Server.dataset.paginate((params[:page] || 1), 10)
      haml :'servers/index', :locals => { :servers => servers }
    end

    get '/servers/new' do
      server = Server.create(:image_id => params[:image_id])
      server.task_dispatcher(:deploy_server_worker)
      flash[:notice] = "Server ##{server.id} deployment initiated."
      redirect url("/servers")
    end

    get '/servers/:id/destroy' do
      server = Server[params['id']]
      if params['force']
        server.destroy
        flash[:notice] = "Server #{server.image.name} was succesfully removed."
      else
        server.task_dispatcher(:server_destroy_worker)
        flash[:notice] = "Server #{server.image.name} was succesfully scheduled for removal."
      end
      Event.create(:message => flash[:notice])
      redirect back
    end

    get '/servers/:id' do
      server = Server[params['id']]
      haml :'servers/show', :locals => { :server => server }
    end

  end
end
