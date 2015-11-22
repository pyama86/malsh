require 'slack-notifier'
module Sac::Notification
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
      %i(slack_webhook slack_channel).all? {|k| Sac.options.key?(k) || ENV[k.to_s.upcase] }
    end

    def self.notifier
      ::Slack::Notifier.new(
        ENV["SLACK_WEBHOOK"] || Sac.options[:slack_webhook],
        channel: ENV["SLACK_CHANNEL"] || Sac.options[:slack_channel],
        username: ENV["SLACK_USER"] || Sac.options[:slack_user] || 'Mackerel-Check',
        link_names: 1
      )
    end
  end
end
