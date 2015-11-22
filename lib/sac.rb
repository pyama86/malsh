require "sac/version"
require 'thor'
require 'mackerel-rb'
require "sac/cli"
require "sac/notification"

module Sac

  def self.notify(subject, host)
    Sac::Notification.constants.each do |c|
      Object.const_get("Sac::Notification::#{c}").notify(self.options[:subject] || subject, host)
    end
  end

  def self.options(ops=nil)
    @_options = ops if ops
    @_options
  end

  def self.init(options)
    self.options options
    Mackerel.configure do |config|
      config.api_key = ENV['MACKEREL_APIKEY'] || options[:api_key]
    end
  end

  def self.hosts
    @_hosts ||= Mackerel.hosts.reject {|h| Sac.options[:invert_match] && Sac.options[:invert_match].find {|v| h.name.match(/#{v}/)}}
  end

  def self.host_by_id(id)
    hosts.find {|h| h.id == id}
  end

  def self.metrics(name)
    hash = {}
    self.hosts.map(&:id).each_slice(200) do |ids|
      hash.merge!(Mackerel.latest_tsdb({hostId: ids, name: name}))
    end
    hash
  end
end


