require_relative './workers/task_helper'
require_relative './workers/task_worker'

# Initialize *all* stuff when running from inside Sidekiq
#
unless Object.const_defined? 'DB'
  require_relative './cloud_manage'
end
