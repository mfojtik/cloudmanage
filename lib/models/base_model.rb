module CloudManage::Models
  module BaseModel
    include CloudManage::Workers

    def log(message, severity=nil)
      add_event(:message => message, :severity => severity || 'INFO')
    end

    def model_name
      self.class.name.split('::').last
    end

    def model_class
      model_name.underscore
    end

    def worker_class(worker_name)
      CloudManage::Workers.const_get(model_name).const_get(worker_name.to_s.camelize)
    end

    def task_dispatcher(worker_name)
      task = Task.prepare(
        worker_name,
        {
          :id => self.id,
          :model => model_class
        }
      )
      if task.exists?
        worker_class("#{worker_name}_worker").perform_async(task.id)
      else
        raise "Unable to dispatch #{task.inspect}"
      end
    end

  end
end
