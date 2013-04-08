
namespace :db do
  desc 'Create or update the database'
  task :migrate do
    require_relative './lib/cloud_manage'
    CloudManage.create_or_update_database!
  end
end
