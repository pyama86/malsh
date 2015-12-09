require 'malsh'
require 'parallel'
require 'pp'
module Malsh
  class CLI < Thor
    class_option :slack_webhook, :type => :string, :aliases => :sw
    class_option :slack_channel, :type => :string, :aliases => :sc
    class_option :slack_user, :type => :string, :aliases => :su
    class_option :api_key, :type => :string, :aliases => :k
    class_option :subject, :type => :string, :aliases => :s
    class_option :invert_match, :type => :array, :aliases => :v
    class_option :regexp,:type => :array, :aliases => :e

    desc 'retire', 'check forget retire host'
    def retire
      Malsh.init options

      host_names = Parallel.map(Malsh.metrics('loadavg5')) do|lvg|
        host = Malsh.host_by_id lvg.first
        host.name if (!lvg.last.loadavg5.respond_to?(:value) || !lvg.last.loadavg5.value)
      end.flatten.compact

      Malsh.notify("退役未了ホスト一覧", host_names)
    end

    desc 'maverick', 'check no role'
    def maverick
      Malsh.init options

      host_names = Parallel.map(Malsh.hosts) do |h|
        h.name if h.roles.keys.size < 1
      end.flatten.compact

      Malsh.notify("ロール無所属ホスト一覧", host_names)
    end

    desc 'search', 'search hosts'
    option :past_date , :type => :numeric, :aliases => :p
    option :cpu_threshold, :type => :numeric, :aliases => :c
    option :memory_threshold, :type => :numeric, :aliases => :m
    def search
      _host_names = {}
      Malsh.init options

      hosts = Malsh.hosts
      Object.const_get("Malsh::HostMetrics").constants.each do |c|
        hosts = Object.const_get("Malsh::HostMetrics::#{c}").check(hosts)
      end
      Malsh.notify("ホスト一覧", hosts.compact.map {|h| h["name"]})
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
