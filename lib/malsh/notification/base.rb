module Malsh::Notification
  class Base
    def self.notify(subject, hosts)
      puts "#{subject}: \n#{hosts.join("\n")}" if hosts.size > 0 && doit?
    end

    def self.doit?
      true
    end
  end
end
