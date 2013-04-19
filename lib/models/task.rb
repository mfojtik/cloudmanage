require_relative './../workers/task_helper'

module CloudManage::Models
  class Task < Sequel::Model

    include BaseModel
    include CloudManage::Workers::TaskHelper

    self.use_transactions=false

    one_to_many :events

    plugin :timestamps, :create => :created_at
    plugin :association_dependencies,
      :events => :delete

    def self.prepare(worker_klass, opts={})
      create(
        :worker_klass => worker_klass,
        :params => JSON::dump(opts),
        :parent_id => opts[:parent_id]
      )
    end

    def change_state(state, msg=nil)
      if update(:state => state.to_s.upcase)
        log(msg || "State changed to #{self.state}", msg ? 'ERROR' : 'INFO')
      end
    end

    def parse_params
      if !self.params.nil? and !self.params.empty?
        begin
          JSON::parse(self.params)
        rescue
          change_state(:error, "Wrong parameters (#{params})")
          {}
        end
      else
        {}
      end
    end

    def name
      worker_klass.camelize.gsub(/Worker$/, '')
    end

    def completed?
      true if ['ERROR', 'COMPLETE'].include?(state)
    end

  end
end
