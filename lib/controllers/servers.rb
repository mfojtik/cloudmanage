module CloudManage::Controllers
  class Servers < Base

    get '/servers' do
      haml :'servers/index', :locals => { :servers => Server.dataset.paginate(page, 25) }
    end

    post '/servers' do
      server = Server.create(:image_id => params['image']['id'])
      params['recipe'].each { |recipe_id, val|
        server.add_recipe(Recipe[recipe_id]) if val == 'on'
      } if params['recipe']
      server.task_dispatcher(:deploy)
      flash[:notice] = "Server ##{server.id} deployment initiated."
      redirect url("/servers")
    end

    get '/servers/:id/destroy' do
      server = Server[params['id']]
      if params['force']
        server.destroy
        flash[:notice] = "Server #{server.image.name} was succesfully removed."
      else
        server.task_dispatcher(:destroy)
        flash[:notice] = "Server #{server.image.name} was succesfully scheduled for removal."
      end
      Event.create(:message => flash[:notice])
      redirect back
    end

    get '/servers/:id/connect' do
      server = Server[params['id']]
      server.task_dispatcher(:connect)
      redirect(back)
    end

    get '/servers/:id' do
      haml :'servers/show', :locals => { :server => Server[params[:id]] }
    end

  end
end
