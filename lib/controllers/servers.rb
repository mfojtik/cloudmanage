module CloudManage::Controllers
  class Servers < Base

    get '/servers' do
      servers = Server.dataset.paginate((params[:page] || 1), 10)
      haml :'servers/index', :locals => { :servers => servers }
    end

    get '/servers/new' do
      server = Server.create(:image_id => params[:image_id])
      server.task.run(:server, :deploy, :server_id => server.id)
      flash[:notice] = "Server ##{server.id} deployment started."
      redirect url("/servers")
    end

    get '/servers/:id/destroy' do
      server = Server[params['id']]
      server.task.run(:server, :remove, :server_id => server.id)
      flash[:notice] = "Server #{server.image.name} is now being deleted."
      Event.create(:message => flash[:notice])
      redirect back
    end

    get '/servers/:id' do
      server = Server[params['id']]
      haml :'servers/show', :locals => { :server => server }
    end

  end
end
