module CloudManage::Workers::Helpers
  module BaseTaskHelper

    def task
      CloudManage::Models::Task
    end

    def on_background(method_name, params={})
      task.run(self.class.model_name, method_name, params)
    end

    module ClassMethods
      def model_name
        self.name.split('::').last.underscore
      end
    end

  end
end
