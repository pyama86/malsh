require 'sac'
require 'pp'
module Sac
  class CLI < Thor
    class_option :slack_webhook, :type => :string, :aliases => :sw
    class_option :slack_channel, :type => :string, :aliases => :sc
    class_option :api_key, :type => :string, :aliases => :k
    class_option :subject, :type => :string, :aliases => :s
    class_option :invert_match, :type => :array, :aliases => :v

    desc 'retire', 'check forget retire host'
    def retire
      names = []
      Sac.init options

      Sac.hosts.map.each_slice(200) do |hs|
        lvgs = Mackerel.latest_tsdb({hostId: hs.map(&:id), name: 'loadavg5'})

        names << hs.map do |host|
          host.name if (!lvgs[host.id].loadavg5.respond_to? :value || lvgs[host.id].loadavg5.value == 0) && !invert?(host)
        end
      end

      Sac.notify("退役未了ホスト一覧", names.flatten.compact)
    end

    desc 'find', 'find by hostname'
    option :regexp, :require => true, :type => :array, :aliases => :e
    def find
      Sac.init options

      names = Sac.hosts.map do |h|
        h.name if options[:regexp].find{|r| h.name.match(/#{r}/)} && !invert?(h)
      end.flatten.compact

      Sac.notify("不要ホスト候補一覧", names.flatten.compact)
    end

    desc 'maverick', 'check no role'
    def maverick
      Sac.init options

      names = Sac.hosts.map do |h|
        h.name if h.roles.keys.size < 1 && !invert?(h)
      end.flatten.compact

      Sac.notify("ロール無所属ホスト一覧", names.flatten.compact)
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      Sac.options = options
      puts Pec::VERSION
    end

    no_commands do
      def invert?(host)
        Sac.options[:invert_match] && Sac.options[:invert_match].find {|v| host.name.match(/#{v}/)}
      end
    end
  end
end
