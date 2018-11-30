module Malsh::Notification
  class Base
    def self.notify_host(subject, hosts)
      names = hosts.map(&:name)
      puts "#{subject}: \n#{names.join("\n")}" if names.size > 0 && doit?
    end

    def self.notify_alert(subject, alerts)
      puts "#{subject}: "
      alerts.each do |alert|
        title = case alert.type
                when 'external'
                  alert.monitor.name
                else
                  alert.host.name
                end
        puts "#{title}: #{alert.message}"
      end
    end

    def self.doit?
      true
    end
  end
end
