#!/usr/bin/ruby 

require 'sensu-plugin/check/cli'
require 'resque'
require 'socket'
require 'resque/failure/redis'

class Resque_failed_jobs < Sensu::Plugin::Check::CLI

  option :hostname,
    :short => "-h HOSTNAME",
    :long => "--host HOSTNAME",
    :description => "Redis hostname",
    :required => true

  option :critical_threshold,
    :description => "Critical threshold",
    :short => '-c CRITICAL THRESHOLD',
    :long => '--critical CRITICAL THRESHOLD'

  option :warning_threshold,
    :description => "Warning threshold",
    :short => '-w WARNING_THRESHOLD',
    :long => '--warning WARNING_THRESHOLD'

def run

redis = Redis.new(:host => config[:hostname])
Resque.redis = redis

count = Resque::Failure::Redis.count

def critical_failed
  unknown "No critical threshold specified" unless config[:critical_threshold]
  config[:critical_threshold].to_i
end

def warning_failed
   unknown "No critical threshold specified" unless config[:warning_threshold]
   config[:warning_threshold].to_i
end

if count >= critical_failed
  output "Critical failed number of jobs"
  critical
elsif count >= warning_failed
  output "Warning failed number of jobs"
  warning
else
  ok
end

end
end