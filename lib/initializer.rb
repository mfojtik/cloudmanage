#
# Initialize database connection
#

require 'logger'
require_relative './core_ext/string'


module CloudManage

  class CustomLogger < Logger
    alias format_message_colorless format_message

    def format_message(level, *args)
      level_str = level == 'ERROR' ? level.light_red : level.light_magenta
      "%-10s: %s %s\n" % [level_str, args[0].strftime("%H:%m:%S").light_green, args.last]
    end
  end

  class JavaLogger < TorqueBox::Logger; end

  def self.logger
    if RUBY_PLATFORM == 'java'
      @logger ||= JavaLogger.new
    else
      @logger ||= CustomLogger.new($stdout)
    end
  end

  def self.connect
    if RUBY_PLATFORM == 'java'
      require 'torquebox/injectors' if RUBY_PLATFORM == 'java'
      ::Sequel.connect(
        'jdbc:sqlite:/home/mfojtik/code/cloudmanage/cm.sqlite',
        :logger => logger
      )
    else
      ::Sequel.connect(
        'sqlite://cm.sqlite',
        :logger => logger
      )
    end
  end

  Sequel::Model.plugin :validation_helpers
  Sequel.extension :pagination

  def self.create_or_update_database!
    DB.create_table? :accounts do
      primary_key :id
      column      :name,          :string, :unique => true, :null => false
      column      :driver,        :string, :null => false
      column      :username,      :string, :null => false
      column      :password,      :string, :null => false
      column      :provider_url,  :string
      column      :updated_at,    :timestamp
      column      :created_at,    :timestamp
    end
    DB.create_table? :images do
      primary_key :id
      column      :account_id,    :integer, :null => false, :index => true
      column      :key_id,        :integer
      column      :name,          :string, :null => false
      column      :image_id,      :string, :null => false, :unique => true
      column      :hwp_id,        :string, :default => ''
      column      :hwp_cpu,       :string, :default => ''
      column      :hwp_memory,    :string, :default => ''
      column      :hwp_storage,   :string, :default => ''
      column      :realm_id,      :string, :default => ''
      column      :firewall_id,   :string, :default => ''
      column      :description,   :string
      column      :starred,       :boolean, :default => false
      column      :updated_at,    :timestamp
      column      :created_at,    :timestamp
    end
    DB.create_table? :keys do
      primary_key :id
      column      :account_id,    :integer, :null => false, :index => true
      column      :name,      :string
      column      :pem,       :string, :size => 1024, :default => ''
      column      :username,   :string, :default => 'root'
      column      :password,   :string
      column      :cmd,        :string, :size => 128
      column      :backend_id, :string
      column      :updated_at,    :timestamp
      column      :created_at,    :timestamp
    end
    DB.create_table? :servers do
      primary_key :id
      column      :instance_id, :string
      column      :image_id, :integer, :null => false, :index => true
      column      :state, :string, :default => 'new'
      column      :address,       :string
      column      :updated_at,    :timestamp
      column      :created_at,    :timestamp
    end
    DB.create_table? :events do
      primary_key :id
      column      :server_id,  :integer, :index => true
      column      :account_id, :integer, :index => true
      column      :key_id,     :integer, :index => true
      column      :image_id,   :integer, :index => true
      column      :severity,   :string,  :default => 'INFO', :null => false
      column      :message,    :string,  :size => 256
      column      :created_at, :timestamp
    end
  end

end

DB = CloudManage.connect
CloudManage.create_or_update_database!

require_relative './models'
require_relative './controllers'
