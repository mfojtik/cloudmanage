module CloudManage::Controllers
  class Servers < Base

    get '/servers' do
      servers = Server.dataset.paginate((params[:page] || 1), 10)
      haml :'servers/index', :locals => { :servers => servers }
    end

    get '/servers/new' do
      server = Server.create_from_image(params['image_id'])
      flash[:notice] = "Server #{server.image.name} has been queued for launch."
      server.add_event(:message => flash[:notice])
      redirect url("/servers")
    end

    get '/servers/:id/destroy' do
      server = Server[params['id']]
      server.destroy
      flash[:notice] = "Server #{server.image.name} has been deleted."
      Event.create(:message => flash[:notice])
      redirect back
    end

  end
end
