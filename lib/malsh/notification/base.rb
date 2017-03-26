module Malsh::Notification
  class Base
    def self.notify(subject, hosts)
      names = hosts.map(&:name)
      puts "#{subject}: \n#{names.join("\n")}" if names.size > 0 && doit?
    end

    def self.doit?
      true
    end
  end
end
