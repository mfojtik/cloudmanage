namespace :db do
  desc 'Create initial database schema'
  task :create do
    require_relative './lib/cloud_manage'
    begin
      CloudManage.create_schema!
    rescue => e
      puts "======== ERROR ========\n#{e.message}\n\n"
      Rake::Task["db:drop"].invoke
    end
  end

  desc 'Clean database'
  task :drop do
    require_relative './lib/cloud_manage'
    DB.tables.reverse.each do |t|
      DB.drop_table t
    end
  end

  desc 'Reset database'
  task :reset do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
  end
end
