module Malsh::HostMetrics
  class Base
    class << self
      def check(hosts)
        to  = Time.now.to_i
        # 7 = 1week
        from = to - (Malsh.options[:past_date] || 7) * 86400

        if Malsh.options[option_name]
          Parallel.map(hosts) do |h|
            value = get_max_usage(h, from, to) if h
            h if value && lower?(value)
          end || []
        else
          hosts
        end
      end

      def resources
        []
      end

      def get_max_value(host_metrics)
        []
      end

      def normalize_result(max, host)
        []
      end

      def all_keys?(metrics)
        resources.all? {|k| metrics.keys.include?(k) }
      end

      def lower?(value)
        value < Malsh.options[option_name]
      end

      def option_name
        nil
      end

      def get_max_usage(host, from, to)
        host_metrics = get_host_metrics(host, from, to)
        max = get_max_value(host_metrics) if host_metrics
        normalize_result(max, host) if max
      end

      def get_host_metrics(host, from, to)
        resources.each_with_object(Hash.new { |h,k| h[k] = {} }) do |name,hash|
          Malsh.host_metrics(host["id"], name, from, to).metrics.each do |v|
            hash[v.time][name] = v.value
          end
        end
      end
    end
  end
end
