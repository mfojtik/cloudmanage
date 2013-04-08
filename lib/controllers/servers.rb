module CloudManage::Controllers
  class Servers < Base

    get '/servers' do
      servers = Server.dataset.paginate((params[:page] || 1), 10)
      haml :'servers/index', :locals => { :servers => servers }
    end

    get '/servers/new' do
      server = Server.create_from_image(params['image_id'])
      flash[:notice] = "Server #{server.image.name} queued for launch."
      redirect url("/servers")
    end

  end
end
