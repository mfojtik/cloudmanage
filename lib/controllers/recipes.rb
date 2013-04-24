module CloudManage::Controllers
  class Recipes < Base

    set :haml, { :ugly => true }

    post '/recipes' do
      if recipe_id = params['recipe'].delete('id')
        recipe = Recipe[recipe_id].update(params['recipe'])
      else
        recipe = Recipe.new(params['recipe'])
      end
      report_error_for(recipe) unless recipe.valid?
      recipe.save
      flash[:notice] = "Recipe succesfully added."
      redirect "/recipes/#{recipe.id}"
    end

    get '/recipes' do
      haml :'recipes/index', :locals => { :recipes => Recipe.dataset.paginate(page, 10) }
    end

    get '/recipes/new' do
      haml :'recipes/new', :locals => { :recipe => Recipe.new }
    end

    get '/recipes/:id/edit' do
      haml :'recipes/new', :locals => { :recipe => Recipe[params[:id]] }
    end

    get '/recipes/:id/destroy' do
      recipe = Recipe[params[:id]]
      recipe.destroy
      flash[:notice] = "recipe #{recipe.name} has been deleted"
      redirect back
    end

    get '/recipes/:id' do
      haml :'recipes/show', :locals => { :recipe => Recipe[params[:id]] }
    end

  end
end
