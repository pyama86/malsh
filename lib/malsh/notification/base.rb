module Malsh::Notification
  class Base
    def self.notify_host(subject, hosts)
      puts "#{subject}:"
      hosts.map do |h|
        puts "#{h.name}(#{h.roles.keys.join(",")})"
      end if doit?
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
