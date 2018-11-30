require 'slack-notifier'
module Malsh::Notification
  class Slack < Base
    def self.notify_host(subject, hosts)
      return unless doit?
      lists = if Malsh.options[:org]
                hosts.map do |h|
                  "<https://mackerel.io/orgs/#{Malsh.options[:org]}/hosts/#{h.id}/-/setting|#{h.name}>"
                end
              else
                hosts.map(&:name)
              end
      note = {
        text: lists.join("\n"),
        color: "warning"
      }
      notifier.ping "*#{subject}*", attachments: [note]
    end

    def self.notify_alert(subject, alerts)
      org = Mackerel.org.name
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

        title = case alert.type
                when 'external'
                  alert.monitor.name
                else
                  alert.host.name
                end

        author_name = case alert.type
                      when 'external'
                        ''
                      else
                        alert.host.roles.map{|k, v| v.map{|r| "#{k}: #{r}"}}.flatten.join(" ")
                      end

        attachments << {
            author_name: author_name,
            title: title,
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
      notifier.ping "*#{subject}*", attachments: attachments
    end

    def self.doit?
      %i(slack_webhook slack_channel).all? {|k| Malsh.options.key?(k) || ENV[k.to_s.upcase] }
    end

    def self.notifier
      ::Slack::Notifier.new(
        ENV["SLACK_WEBHOOK"] || Malsh.options[:slack_webhook],
        channel: ENV["SLACK_CHANNEL"] || Malsh.options[:slack_channel],
        username: ENV["SLACK_USER"] || Malsh.options[:slack_user] || 'Mackerel-Check',
        link_names: 1
      )
    end
  end
end
