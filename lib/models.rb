if DB.table_exists? :servers
  require_relative './workers'
  require_relative './models/base_model'

  # Load Sequel Models
  #
  [:account, :image, :key, :server, :event, :task, :resource].each do |t|
    require_relative "./models/#{t}"
  end
end
