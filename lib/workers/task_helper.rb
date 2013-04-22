module CloudManage
  module Workers
    module TaskHelper

      class Retry < StandardError
        def backtrace; []; end
      end

      def setup_task(task_id)
        @task = CloudManage::Models::Task[task_id]
        return false if task_is_nil?(task_id)
        return false if @task.completed?
        if @task.state == 'PENDING'
          true
        else
          @task.change_state(:pending)
        end
      end

      def task_is_nil?(task_id)
        if @task.nil?
          CloudManage::Models::Event.create(:severity => 'ERROR', :message => "Task does not exists #{task_id}")
          return true
        end
      end

      def retry_task
        raise Retry
      end

      def populate_account_with(entity, task_id)
        return unless setup_task(task_id)
        account = Models::Account[@task.parse_params['id']]
        counter = 0
        res = account.client.send(entity)
        res.each do |r|
          if current_res = account.send("#{entity.to_s.singularize}_exists?", r._id)
            current_res.update(:name => r.name)
          else
            account.add_resource(
              :kind => entity.to_s.singularize,
              :resource_id => r._id,
              :name => r.name
            ) && counter += 1
          end
        end
        @task.change_state(:completed)
        account.log("#{counter} new #{entity} were imported")
      end

    end
  end
end
