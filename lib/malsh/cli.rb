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

    desc 'retire', 'check forget retire host'
    def retire
      Malsh.init options

      host_names = Malsh.metrics('loadavg5').map do|lvg|
        host = Malsh.host_by_id lvg.first
        host.name if (!lvg.last.loadavg5.respond_to?(:value) || !lvg.last.loadavg5.value)
      end.flatten.compact

      Malsh.notify("退役未了ホスト一覧", host_names)
    end

    desc 'find', 'find by hostname'
    option :regexp, :required => true, :type => :array, :aliases => :e
    def find
      Malsh.init options

      host_names = Malsh.hosts.map do |h|
        h.name if options[:regexp].find{|r| h.name.match(/#{r}/)}
      end.flatten.compact

      Malsh.notify("不要ホスト候補一覧", host_names)
    end

    desc 'maverick', 'check no role'
    def maverick
      Malsh.init options

      host_names = Malsh.hosts.map do |h|
        h.name if h.roles.keys.size < 1
      end.flatten.compact

      Malsh.notify("ロール無所属ホスト一覧", host_names)
    end

    desc 'obese', 'check obese hosts'
    option :past_date , :type => :numeric, :aliases => :p
    option :cpu_threshold, :type => :numeric, :aliases => :c
    option :memory_threshold, :type => :numeric, :aliases => :m
    def obese
      resources = %w(cpu memory)
      _host_names = {}

      Malsh.init options
      now = Time.now.to_i
      # 7 = 1week
      from = now - (options[:past_date] || 7) * 86400

      resources.each do |resource|
        _host_names[resource] = Parallel.map(Malsh.hosts) do |h|
          value = self.send("max_#{resource}_usage", h, from, now)
          value < options["#{resource}_threshold".to_sym] ? h["name"] : nil
        end.flatten.compact.uniq if options["#{resource}_threshold".to_sym]
      end

      host_names = case
      when resources.all? {|r| options["#{r}_threshold".to_sym]}
        _host_names["cpu"] & _host_names["memory"]
      when  r = resources.find {|r| options["#{r}_threshold".to_sym]}
        _host_names[r]
      else
        []
      end
      Malsh.notify("余剰リソースホスト一覧", host_names)
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts Malsh::VERSION
    end

    no_commands do
      def get_host_metrics(resources, host, from, to)
        resources.each_with_object(Hash.new { |h,k| h[k] = {} }) do |name,hash|
          Malsh.host_metrics(host["id"], name, from, to).metrics.each do |v|
            hash[v.time][name] = v.value
          end
        end
      end

      def max_cpu_usage(host, from, to)
        cpu_use_resource = %w(cpu.user.percentage cpu.iowait.percentage cpu.system.percentage cpu.iowait.percentage)
        hash = get_host_metrics(cpu_use_resource, host, from, to)

        max = hash.max_by do |time,cpu|
          cpu_use_resource.map { |name| cpu[name] }.inject(:+)
        end

        cpu_use_resource.map { |name| max.last[name] }.inject(:+) / host["meta"]["cpu"].size
      end

      def max_memory_usage(host, from, to)
        memory_use_resource =  %w(memory.total memory.used memory.cached)
        hash = get_host_metrics(memory_use_resource, host, from, to)

        max = hash.max_by do |time,memory|
          (memory["memory.used"] + memory["memory.cached"]) / memory["memory.total"] * 100 if memory["memory.total"]
        end
          (max.last["memory.used"] + max.last["memory.cached"]) / max.last["memory.total"] * 100
      end
    end
  end
end
