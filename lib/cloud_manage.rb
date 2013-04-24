require 'rubygems'
require 'bundler'
require 'logger'

Bundler.require(:default)

module CloudManage

  module Models
    DELTACLOUD_URL = 'http://localhost:9292/api'
    SCHEMA_VERSION = '1'
  end

  def self.connect
    sequel_class = ::Sequel
    connection = sequel_class.connect(
      'postgres://root@localhost/cloudmanage_dev',
      :logger => ::Logger.new('logs/sequel.log')
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
    DB.create_table :resources do
      primary_key :id
      foreign_key :account_id, :accounts
      String      :kind,          :null => false, :size => 255, :index => true
      String      :resource_id,   :null => false, :size => 255
      String      :name,          :null => false, :size => 255
    end
    DB.create_table :keys do
      primary_key :id
      foreign_key :account_id, :accounts
      String      :name,          :size => 255
      String      :pem
      String      :username,      :size => 255, :default => 'root'
      String      :password,      :size => 255
      String      :cmd
      String      :backend_id,    :size => 10
      DateTime    :updated_at
      DateTime    :created_at
    end
    DB.create_table :images do
      primary_key :id
      foreign_key :account_id, :accounts
      foreign_key :key_id,     :keys
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
    DB.create_table :servers do
      primary_key :id
      foreign_key :image_id,      :images
      String      :instance_id,   :size => 255, :index => true
      String      :state,         :default => 'new', :size => 64
      String      :address,       :size => 255
      DateTime    :updated_at
      DateTime    :created_at
    end
    DB.create_table :metrics do
      primary_key :id
      foreign_key :server_id,    :servers
      String      :name,         :size => 25
      String      :value,        :size => 100
      DateTime    :created_at
    end
    DB.create_table :recipes do
      primary_key :id
      foreign_key :server_id,    :servers
      column      :parent_id,    :integer, :index => true
      String      :name,         :size => 255, :null => false
      String      :body
      DateTime    :created_at
      DateTime    :updated_at
    end
    DB.create_table :recipes_servers do
      primary_key :id
      foreign_key :server_id,    :servers
      foreign_key :recipe_id,    :recipes
    end
    DB.create_table :tasks do
      primary_key :id
      Integer     :parent_id,     :index => true
      String      :worker_klass,  :null => false, :size => 64, :index => true
      String      :params
      String      :state,      :null => false, :default => 'NEW', :size => 32
      DateTime    :created_at
    end
    DB.create_table :events do
      primary_key :id
      foreign_key :server_id,  :servers
      foreign_key :account_id, :accounts
      foreign_key :key_id,     :keys
      foreign_key :image_id,   :images
      foreign_key :task_id,    :tasks
      String      :severity,   :default => 'INFO', :null => false, :size => 10
      String      :message
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

require_relative './models'
