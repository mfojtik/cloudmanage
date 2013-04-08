TorqueBox.configure do

  options_for :jobs, :concurrency => 5

  queue '/queues/import_images' do
    processor CloudManage::ImportImagesProcessor
  end

  queue '/queues/create_instance' do
    processor CloudManage::CreateInstanceProcessor
  end

end
