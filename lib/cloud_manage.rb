require 'rubygems'
require 'bundler'
require 'logger'

Bundler.require(:default)

module CloudManage

  module Models
    DELTACLOUD_URL = 'http://localhost:3002/api'
    SCHEMA_VERSION = '1'
  end

  def self.connect
    sequel_class = ::Sequel
    connection = sequel_class.connect(
      'postgres://root@localhost/cloudmanage_dev',
      :logger => ::Logger.new($stdout)
    )
    sequel_class::Model.plugin :validation_helpers
    sequel_class.extension :pagination
    connection
  end


  def self.create_schema!
    DB.create_table :accounts do
      primary_key :id
      String      :name,          :unique => true, :null => false, :size => 255
      String      :driver,        :null => false, :size => 255
      String      :username,      :null => false, :size => 255
      String      :password,      :null => false, :size => 255
      String      :provider_url,  :size => 255
      DateTime    :updated_at
      DateTime    :created_at
    end
    DB.create_table :images do
      primary_key :id
      Integer     :account_id,    :null => false, :index => true
      Integer     :key_id
      String      :name,          :null => false, :size => 255
      String      :image_id,      :null => false, :unique => true, :size => 255
      String      :hwp_id,        :default => '', :size => 255
      String      :hwp_cpu,       :default => '', :size => 255
      String      :hwp_memory,    :default => '', :size => 255
      String      :hwp_storage,   :default => '', :size => 255
      String      :realm_id,      :default => '', :size => 255
      String      :firewall_id,   :default => '', :size => 255
      String      :description
      Boolean     :starred,       :default => false
      DateTime    :updated_at
      DateTime    :created_at
    end
    DB.create_table :keys do
      primary_key :id
      column      :account_id,    :integer, :null => false, :index => true
      String      :name,          :size => 255
      String      :pem
      String      :username,      :size => 255, :default => 'root'
      String      :password,      :size => 255
      String      :cmd
      String      :backend_id,    :size => 10
      DateTime    :updated_at
      DateTime    :created_at
    end
    DB.create_table :servers do
      primary_key :id
      String      :instance_id,   :size => 10, :index => true
      Integer     :image_id,      :null => false, :index => true
      String      :state,         :default => 'new', :size => 64
      String      :address,       :size => 255
      DateTime    :updated_at
      DateTime    :created_at
    end
    DB.create_table :events do
      primary_key :id
      Integer     :server_id,  :index => true
      Integer     :account_id, :index => true
      Integer     :key_id,     :index => true
      Integer     :image_id,   :index => true
      Integer     :task_id,    :index => true
      String      :severity,   :default => 'INFO', :null => false, :size => 10
      String      :message,    :size => 255
      DateTime    :created_at
    end
    DB.create_table :tasks do
      primary_key :id
      Integer     :parent_id,  :index => true
      String      :klass,      :null => false, :size => 64, :index => true
      String      :name,       :null => false, :size => 64
      String      :params
      String      :state,      :null => false, :default => 'NEW', :size => 32
      DateTime    :created_at
    end
  end
end

# Core extensions
#
require_relative './core_ext/string'

# Initialize the database
#
DB = CloudManage.connect

if DB.table_exists? :servers
  require_relative './workers'

  # Load Sequel Models
  #
  [:account, :image, :key, :server, :event, :task].each do |t|
    require_relative "./cloud_manage/models/#{t}"
  end
end
