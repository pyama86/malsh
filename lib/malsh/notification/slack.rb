require 'slack-notifier'
module Malsh::Notification
  class Slack < Base
    def self.notify(subject, hosts)
      return unless doit?
      note = {
        text: hosts.join("\n"),
        color: "warning"
      }
      notifier.ping "*#{subject}*", attachments: [note]
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
