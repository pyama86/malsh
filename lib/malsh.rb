require "malsh/version"
require 'thor'
require 'mackerel-rb'
require "malsh/cli"
require "malsh/notification"

module Malsh

  def self.notify(subject, host)
    Malsh::Notification.constants.each do |c|
      Object.const_get("Malsh::Notification::#{c}").notify(self.options[:subject] || subject, host)
    end
  end

  def self.options(ops=nil)
    @_options = ops if ops
    @_options
  end

  def self.init(options)
    if !ENV['MACKEREL_APIKEY'] && !options[:api_key]
      puts "must set be mackerel api key <--api-key> or ENV['MACKEREL_APIKEY']"
      exit
    end

    self.options options
    Mackerel.configure do |config|
      config.api_key = ENV['MACKEREL_APIKEY'] || options[:api_key]
    end
  end

  def self.hosts
    @_hosts ||= Mackerel.hosts.reject {|h| Malsh.options[:invert_match] && Malsh.options[:invert_match].find {|v| h.name.match(/#{v}/)}}
  end

  def self.host_by_id(id)
    Mackerel.host(id)
  end

  def self.metrics(name)
    hash = {}
    self.hosts.map(&:id).each_slice(200) do |ids|
      hash.merge!(Mackerel.latest_tsdb({hostId: ids, name: name}))
    end
    hash
  end
end


