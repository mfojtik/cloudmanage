module CloudManage::Models
  class Task < Sequel::Model

    one_to_many :events

    plugin :timestamps,
      :create => :created_at

    plugin :association_dependencies,
      :events => :delete


    def self.run(klass_name, method, opts={})
      new_task = new(:klass => klass_name, :name => method, :params => JSON::dump(opts))
      if new_task.valid?
        new_task.save
      else
        raise "Cannot created new Task (#{new_task.errors})"
      end
    end

    def change_state(state, msg=nil)
      if update(:state => state.to_s.upcase)
        add_event(:message => msg || "Task state changed to #{self.state}", :severity => msg ? 'ERROR' : 'INFO')
      end
    end

    def klass_ent
      begin
        CloudManage::Models.const_get(self.klass.camelize)
      rescue NameError
        change_state(:error, "Task contains unresolvable model class (#{self.klass.camelize})")
        false
      end
    end

    def load_params
      if !self.params.nil? and !self.params.empty?
        begin
          JSON::parse(self.params)
        rescue
          change_state(:error, "Unable to parse Task parameters (#{params})")
          {}
        end
      else
        {}
      end
    end

    def completed?
      true if ['ERROR', 'COMPLETE'].include?(state)
    end

    def after_create
      CloudManage::Workers::TaskWorker.perform_async(self.id)
      super
    end

  end
end
