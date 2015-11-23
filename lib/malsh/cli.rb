require 'malsh'
require 'pp'
module Malsh
  class CLI < Thor
    class_option :slack_webhook, :type => :string, :aliases => :sw
    class_option :slack_channel, :type => :string, :aliases => :sc
    class_option :slack_user, :type => :string, :aliases => :su
    class_option :api_key, :type => :string, :aliases => :k
    class_option :subject, :type => :string, :aliases => :s
    class_option :invert_match, :type => :array, :aliases => :v

    desc 'retire', 'check forget retire host'
    def retire
      Malsh.init options

      names = Malsh.metrics('loadavg5').map do|lvg|
        host = Malsh.host_by_id lvg.first
        host.name if (!lvg.last.loadavg5.respond_to?(:value) || !lvg.last.loadavg5.value)
      end.flatten.compact
      Malsh.notify("退役未了ホスト一覧", names)
    end

    desc 'find', 'find by hostname'
    option :regexp, :require => true, :type => :array, :aliases => :e
    def find
      Malsh.init options

      names = Malsh.hosts.map do |h|
        h.name if options[:regexp].find{|r| h.name.match(/#{r}/)}
      end.flatten.compact

      Malsh.notify("不要ホスト候補一覧", names.flatten.compact)
    end

    desc 'maverick', 'check no role'
    def maverick
      Malsh.init options

      names = Malsh.hosts.map do |h|
        h.name if h.roles.keys.size < 1
      end.flatten.compact

      Malsh.notify("ロール無所属ホスト一覧", names.flatten.compact)
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts Malsh::VERSION
    end

    no_commands do
    end
  end
end
