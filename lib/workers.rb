require_relative './workers/task_helper'

# Initialize *all* stuff when running from inside Sidekiq
#
unless Object.const_defined? 'DB'
  require_relative './cloud_manage'
end

# Worker classes
#
# Server workers:
require_relative './workers/server/address_worker'
require_relative './workers/server/deploy_worker'
require_relative './workers/server/start_worker'
require_relative './workers/server/stop_worker'
require_relative './workers/server/destroy_worker'
require_relative './workers/server/running_worker'
require_relative './workers/server/connect_worker'
require_relative './workers/server/metrics_worker'
require_relative './workers/server/recipe_worker'

# Account workers:
#
require_relative './workers/account/firewalls_worker.rb'
require_relative './workers/account/realms_worker.rb'
require_relative './workers/account/hardware_profiles_worker.rb'
require_relative './workers/account/images_worker.rb'
require_relative './workers/account/instances_worker.rb'
