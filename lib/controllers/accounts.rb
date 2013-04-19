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
      accounts = Account.dataset.paginate((params[:page] || 1), 10)
      haml :'accounts/index', :locals => { :accounts => accounts }
    end

    get '/accounts/new' do
      haml :'accounts/new', :locals => { :account => Account.new }
    end

    get '/accounts/:id/edit' do
      account = Account[params[:id]]
      haml :'accounts/new', :locals => { :account => account }
    end

    get '/accounts/:id/destroy' do
      account = Account[params[:id]]
      account.destroy
      flash[:notice] = "Account #{account.name} has been deleted"
      redirect back
    end

    get '/accounts/:id/populate' do
      account = Account[params[:id]]
      if params.has_key? 'images'
        account.task_dispatcher(:import_images_worker)
      elsif params.has_key? 'realms'
        account.task_dispatcher(:populate_realms_worker)
      elsif params.has_key? 'firewalls'
        account.task_dispatcher(:populate_firewalls_worker)
      end
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
      account = Account[params[:id]]
      haml :'accounts/show', :locals => { :account => account }
    end

  end
end
