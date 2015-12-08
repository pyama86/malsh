module Malsh::HostMetrics
  class Memory < Base
    class << self
      def resources
        %w(memory.total memory.used memory.cached)
      end

      def get_max_value(host_metrics)
        host_metrics.max_by do |time,memory|
          resources.map { |name| memory[name] }.inject(:+) if all_keys?(memory)
          (memory["memory.used"] + memory["memory.cached"]) / memory["memory.total"] * 100 if all_keys?(memory)
        end
      end

      def normalize_result(max, host)
        (max.last["memory.used"] + max.last["memory.cached"]) / max.last["memory.total"] * 100
      end

      def option_name
        :memory_threshold
      end
    end
  end
end
