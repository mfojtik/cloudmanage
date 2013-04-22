module CloudManage::Controllers
  class Images < Base

    get '/images/:id' do
      haml :'images/show', :locals => { :image => Image[params[:id]] }
    end

    get '/images/:id/edit' do
      haml :'images/edit', :locals => { :image => Image[params[:id]] }
    end

    post '/images' do
      image_id = params['image'].delete('id')
      image = Image[image_id].update(params['image'])
      report_error_for(image) unless image.valid?
      image.save
      flash[:notice] = "Image #{image.image_id} updated."
      redirect "/images/#{image_id}"
    end

    get '/images' do
      images = Image.where(:starred => true).paginate(page, 25)
      haml :'images/index', :locals => { :images => images }
    end

    get '/images/:id/launch' do
      haml :'images/launch', :locals => { :image => Image[params[:id]] }
    end

    get '/images/:id/favorite' do
      image = Image[params[:id]]
      image.update(:starred => (params['remove'] ? false : true))
      redirect "/images"
    end

  end
end
