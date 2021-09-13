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
        title = if Malsh.alert_has_host?(alert)
                  alert.host.name
                else
                  alert.monitor.name
                end
        puts "#{title}: #{alert.message}"
      end
    end

    def self.doit?
      true
    end
  end
end
