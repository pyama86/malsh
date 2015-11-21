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
    @_hosts ||= Mackerel.hosts
  end
end


