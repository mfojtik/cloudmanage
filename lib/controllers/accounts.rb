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
      redirect "/accounts/#{account.id}"
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

    get '/accounts/:id/import' do
      account = Account[params[:id]]
      account.task.run(:image, :import, :account_id => account.id)
      flash[:notice] = "Importing backend images for #{account.name}. <a href='#{url('/accounts')}'>Refresh</a> at will."
      redirect back
    end

    get '/accounts/:id/images' do
      account = Account[params[:id]]
      images = Image.where(:account_id => account.id).paginate((params[:page] ? params[:page].to_i : 1), 25)
      haml :'accounts/images', :locals => { :account => account, :images => images }
    end

    get '/accounts/:id' do
      account = Account[params[:id]]
      haml :'accounts/show', :locals => { :account => account }
    end

  end
end
