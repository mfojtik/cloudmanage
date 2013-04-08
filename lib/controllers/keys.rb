module CloudManage::Controllers
  class Keys < Base

    get '/keys/:account_id/new' do
      account = Account[params[:account_id]]
      key = Key.new(:account_id => account.id)
      haml :'keys/new', :locals => { :account => account, :key => key }
    end

    get '/accounts/:account_id/keys' do
      account = Account[params[:account_id]]
      keys = Key.where(:account_id => account.id).paginate((params[:page] ? params[:page].to_i : 1), 25)
      haml :'keys/index', :locals => { :keys => keys, :account => account }
    end

    get '/keys/:id' do
      key = Key[params[:id]]
      haml :'keys/show', :locals => { :key => key }
    end

    get '/keys/:id/destroy' do
      key = Key[params[:id]].destroy
      flash[:notice] = "Authentication key #{key.name} was succesfully destroyed."
      redirect back
    end

    post '/keys' do
      key = Key.create_or_update_key(params['key'])
      if key.id
        flash[:notice] = "Authentication key #{key.name} was succesfully created for #{key.account.name}"
        key.add_event(:message => flash[:notice])
        redirect "/keys/#{key.id}"
      else
        flash[:error] = "Authentication key cannot be created"
        redirect back
      end
    end

  end

end
