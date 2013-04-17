require_relative './workers/helpers'

if DB.table_exists? :servers
  require_relative './models/base_model'
  require_relative './workers'

  # Load Sequel Models
  #
  [:account, :image, :key, :server, :event, :task].each do |t|
    require_relative "./models/#{t}"
  end
end
