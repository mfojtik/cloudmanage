module CloudManage::Controllers
  class Images < Base

    get '/images/:id' do
      image = Image[params[:id]]
      haml :'images/show', :locals => { :image => image }
    end

    get '/images/:id/edit' do
      image = Image[params[:id]]
      haml :'images/edit', :locals => { :image => image }
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
      images = Image.where(
        :starred => true).paginate(page, 25)
      haml :'images/index', :locals => { :images => images }
    end

    get '/images/:id/launch' do
      image = Image[params[:id]]
      haml :'images/launch', :locals => { :image => image }
    end

  end
end
