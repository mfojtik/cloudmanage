TorqueBox.configure do

  options_for :jobs, :concurrency => 5

  queue '/queues/import_images' do
    processor CloudManage::ImportImagesProcessor
  end

  queue '/queues/create_instance' do
    processor CloudManage::CreateInstanceProcessor
  end

  queue '/queues/destroy_instance' do
    processor CloudManage::DestroyInstanceProcessor
  end

  job CloudManage::MachineRefresh do
    name 'machine.refresh'
    cron '*/30 * * * * ?'
    timeout '50s'
    description 'Periodically checks for instance state changes'
  end

end
