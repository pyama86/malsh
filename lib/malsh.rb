require 'malsh/version'
require 'thor'
require 'mackerel-rb'
require 'malsh/cli'
require 'malsh/notification'
require 'malsh/host_metrics'

module Malsh
  class << self
    def notify_host(subject, host)
      Malsh::Notification.constants.each do |c|
        Object.const_get("Malsh::Notification::#{c}").notify_host(options[:subject] || subject, host)
      end
    end

    def notify_alert(subject, alerts)
      Malsh::Notification.constants.each do |c|
        Object.const_get("Malsh::Notification::#{c}").notify_alert(options[:subject] || subject, alerts)
      end
    end

    def options(ops = nil)
      @_options = ops if ops
      @_options
    end

    def init(options)
      if !ENV['MACKEREL_APIKEY'] && !options[:api_key]
        puts "must set be mackerel api key <--api-key> or ENV['MACKEREL_APIKEY']"
        exit
      end

      options options
      Mackerel.configure do |config|
        config.api_key = ENV['MACKEREL_APIKEY'] || options[:api_key]
      end
    end

    def hosts(options = {})
      @_hosts ||= Mackerel.hosts(options).reject do |h|
        Malsh.options[:invert_match] && Malsh.options[:invert_match].find { |v| host_name(h).match(/#{v}/) }
      end.reject do |h|
        Malsh.options[:regexp] && Malsh.options[:regexp].all? { |r| !host_name(h).match(/#{r}/) }
      end.reject do |h|
        Malsh.options[:invert_role] && Malsh.options[:invert_role].find do |r|
          service, role = r.split(/:/)
          h.roles[service] && h.roles[service].include?(role)
        end
      end
    end

    def alerts
      @_alerts ||= Mackerel.alerts.map do |alert|
        if alert_has_host?(alert)
          alert['host'] = Malsh.host_by_id(alert.hostId)
        else
          alert['monitor'] = Mackerel.monitor(alert.monitorId)
        end
        alert
      end
    end

    def host_name(host)
      host.displayName || host.name
    end

    def host_by_id(id)
      Mackerel.host(id)
    end

    def metrics(name)
      hash = {}
      hosts.map(&:id).each_slice(200) do |ids|
        hash.merge!(Mackerel.latest_tsdb({ hostId: ids, name: name }))
      end
      hash
    end

    def host_metrics(id, name, from, to)
      Mackerel.host_metrics(id, name: name, from: from, to: to)
    rescue StandardError => e
      puts e
    end

    def host_metric_names(id)
      Mackerel.host_metric_names(id)
    rescue StandardError => e
      puts e
    end

    def alert_has_host?(alert)
      exclude_types = %w[external service expression]
      return false if exclude_types.include?(alert.type)

      true
    end
  end
end
