module CloudManage::Controllers
  class Accounts < Base

    post '/accounts' do
      account_id = params['account'].delete('id')
      if account_id
        account = Account[account_id].update(params['account'])
      else
        account = Account.new(params['account'])
      end
      report_error_for(account) unless account.valid?
      account.save
      flash[:notice] = "Account succesfully saved, please create an authentication keys."
      redirect "/keys/#{account.id}/new"
    end

    get '/accounts' do
      haml :'accounts/index', :locals => { :accounts => Account.dataset.paginate(page, 10) }
    end

    get '/accounts/new' do
      haml :'accounts/new', :locals => { :account => Account.new }
    end

    get '/accounts/:id/edit' do
      haml :'accounts/new', :locals => { :account => Account[params[:id]] }
    end

    get '/accounts/:id/destroy' do
      account = Account[params[:id]]
      account.destroy
      flash[:notice] = "Account #{account.name} has been deleted"
      redirect back
    end

    get '/accounts/:id/populate' do
      Account[params[:id]].task_dispatcher(params.keys.first)
      redirect back
    end

    get '/accounts/:id/images' do
      account = Account[params[:id]]
      if params['q']
        images = account.images_dataset.where(
          Sequel.ilike(:description, "%#{params['q']}%") |
          Sequel.ilike(:name, "%#{params['q']}%")
        ).paginate(page, 25)
      else
        images = Image.where(:account_id => account.id).paginate(page, 25)
      end
      haml :'accounts/images', :locals => { :account => account, :images => images }
    end

    get '/accounts/:id' do
      haml :'accounts/show', :locals => { :account => Account[params[:id]] }
    end

  end
end
