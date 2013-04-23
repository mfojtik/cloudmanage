module CloudManage
  module Workers
    module Server

      class MetricsWorker

        include Sidekiq::Worker
        include CloudManage::Workers::TaskHelper
        include CloudManage::Models

        sidekiq_options :retry => 1, :backtrace => 2

        def perform(server_id)
          server = Models::Server[server_id]
          return unless server.ready?
          begin
            server.console do |ssh|
              parse_metrics(ssh.exec!("vmstat -a | tail -n 1")).each do |m|
                server.add_metric(:name => m[0], :value => m[1])
              end
            end
          rescue => e
            server.log("Unable to fetch metrics (#{e.message})", 'ERROR')
          end
        end

        def parse_metrics(metrics)
          # Parse:
          # procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
          # r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
          # 1  0      0 2151852 484336 2374904    0    0     6    31   98   90  4  2 94  0
          result = []
          arr = metrics.strip.split(' ')
          result << [ 'inact', arr[4] ]
          result << [ 'active', arr[5] ]
          result << [ 'cpu', arr[12]]
          result
        end

      end
    end
  end
end
