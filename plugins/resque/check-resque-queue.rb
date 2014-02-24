#!/usr/bin/ruby 

require 'sensu-plugin/check/cli'
require 'resque'
require 'socket'
require 'resque/failure/redis'

class Resque_queue_length < Sensu::Plugin::Check::CLI

  option :hostname,
    :short => "-h HOSTNAME",
    :long => "--host HOSTNAME",
    :description => "Redis hostname",
    :required => true

  option :queue,
    :description => "Queue name",
    :short => '-q QUEUE NAME',
    :long => '--queue QUEUE NAME'

  option :critical_threshold,
    :description => "Critical threshold",
    :short => '-c CRITICAL THRESHOLD',
    :long => '--critical CRITICAL THRESHOLD'

  option :warning_threshold,
    :description => "Warning threshold",
    :short => '-w WARNING_THRESHOLD',
    :long => '--warning WARNING_THRESHOLD'

redis = Redis.new(:host => config[:hostname])
Resque.redis = redis

def critical_length
  unknown "No critical threshold specified" unless config[:critical_threshold]
  config[:critical_threshold].to_i
end

def warning_length
   unknown "No critical threshold specified" unless config[:warning_threshold]
   config[:warning_threshold].to_i
end

  sz = Resque.size(config[:queue])
  if sz >= critical_length
     crit << "Critical the queue #{v} has currently #{sz}"
     elsif sz >= warning_length
     warn << "Warning the queue #{v} has currently #{sz}"
     else
     puts "#{v} OK"
  end

  def run
    critical usage_summary unless @crit.empty?
    warning usage_summary unless @warn.empty?
    ok "Queue's are fine"
  end
 end

end
