require 'malsh'
require 'parallel'
require 'pp'

class Response < Hashie::Mash
  disable_warnings
end

module   Mackerel
  class Client
    module Org
      def org
        response = get 'org'
        response.body
      end
    end
  end
end

module Mackerel
  class Client
    module Monitor
      def monitor(id)
        response = get "monitors/#{id}"
        p response.body
        response.body.monitor
      end
    end
  end
end


module Mackerel
  class Client
    include Configuration
    include Connection

    include Client::Org
  end
end

module Malsh
  class CLI < Thor
    class_option :slack_webhook, :type => :string, :aliases => :sw
    class_option :slack_channel, :type => :string, :aliases => :sc
    class_option :slack_user, :type => :string, :aliases => :su
    class_option :api_key, :type => :string, :aliases => :k
    class_option :subject, :type => :string, :aliases => :s
    class_option :org, :type => :string, :aliases => :o
    class_option :invert_match, :type => :array, :aliases => :v
    class_option :invert_role, :type => :array, :aliases => :r
    class_option :regexp,:type => :array, :aliases => :e

    desc 'retire', 'check forget retire host'
    def retire
      Malsh.init options

      hosts = Parallel.map(Malsh.metrics('memory.used')) do|memory|
        host = Malsh.host_by_id memory.first
        host if (!memory.last["memory.used"].respond_to?(:value) || !memory.last["memory.used"].value)
      end.flatten.compact

      Malsh.notify("退役未了ホスト一覧", hosts)
    end

    desc 'maverick', 'check no role'
    def maverick
      Malsh.init options

      hosts = Parallel.map(Malsh.hosts) do |h|
        h if h.roles.keys.size < 1
      end.flatten.compact

      Malsh.notify("ロール無所属ホスト一覧", hosts)
    end

    desc 'search', 'search hosts'
    option :past_date , :type => :numeric, :aliases => :p
    option :cpu_threshold, :type => :numeric, :aliases => :c
    option :memory_threshold, :type => :numeric, :aliases => :m
    option :status, :type => :string, :aliases => :st
    def search
      Malsh.init options
      o = options[:status] ? { status: options[:status] } : {}
      hosts = Malsh.hosts(o)
      Object.const_get("Malsh::HostMetrics").constants.each do |c|
        hosts = Object.const_get("Malsh::HostMetrics::#{c}").check(hosts)
      end
      Malsh.notify("ホスト一覧", hosts.compact)
    end


    desc 'alert', 'list alerts'
    def alert
      Malsh.init options
      org = Mackerel.org.name
      alerts = Mackerel.alerts

      attachments = []
      alerts.each do |alert|
        color = case alert.status
                when 'CRITICAL'
                  'danger'
                when 'WARNING'
                  'warning'
                else
                  ''
                end

        if alert.type == 'external'
          monitor = Mackerel.monitor(alert.monitorId)
          attachments << {
              title: monitor.name,
              title_link: "https://mackerel.io/orgs/#{org}/alerts/#{alert.id}",
              text: alert.message,
              color: color,
              fields: [
                  {
                      title: 'Type',
                      value: alert.type
                  },
                  {
                      title: 'OpenedAt',
                      value: Time.at(alert.openedAt).strftime("%Y/%m/%d %H:%M:%S")
                  }
              ]

          }
        else
          host = Malsh.host_by_id(alert.hostId)
          attachments << {
              title: host.name,
              title_link: "https://mackerel.io/orgs/#{org}/alerts/#{alert.id}",
              text: alert.message,
              color: color,
              fields: [
                  {
                      title: 'Type',
                      value: alert.type
                  },
                  {
                      title: 'OpenedAt',
                      value: Time.at(alert.openedAt).strftime("%Y/%m/%d %H:%M:%S")
                  }
              ]
          }

        end

      end
      Malsh::Notification::Slack.notifier.ping "*アラート一覧*", attachments: attachments
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
