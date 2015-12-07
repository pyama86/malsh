module Malsh::HostMetrics
  class Cpu < Base
    class << self
      def resources
        %w(cpu.user.percentage cpu.iowait.percentage cpu.system.percentage)
      end

      def get_max_value(host_metrics)
        host_metrics.max_by do |time,cpu|
          resources.map { |name| cpu[name] }.inject(:+) if all_keys?(cpu)
        end
      end

      def normalize_result(max, host)
        resources.map { |name| max.last[name] }.inject(:+) / host["meta"]["cpu"].size
      end

      def option_name
        :cpu_threshold
      end
    end
  end
end
