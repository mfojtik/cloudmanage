require_relative './workers/task_helper'

# Initialize *all* stuff when running from inside Sidekiq
#
unless Object.const_defined? 'DB'
  require_relative './cloud_manage'
end

# Worker classes
#
require_relative './workers/import_images_worker'
require_relative './workers/populate_realms_worker'
require_relative './workers/populate_hardware_profiles_worker'
require_relative './workers/populate_firewalls_worker'
require_relative './workers/server_running_worker'
require_relative './workers/server_address_worker'
require_relative './workers/server_start_worker'
require_relative './workers/server_stop_worker'
require_relative './workers/server_destroy_worker'
require_relative './workers/deploy_server_worker'
