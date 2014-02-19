require 'sensu-plugin/check/cli'
require 'resque'
require 'socket'
require 'resque/failure/redis'

class Resque_queue_length  < Sensu::Plugin::Check::CLI

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

def run

redis = Redis.new(:host => config[:hostname], :port => config[:port])
Resque.redis = redis

#count = Resque::Failure::Redis.count
#info = Resque.info

Resque.queues.each do |v|

def critical_length
  unknown "No critical threshold specified" unless config[:critical_threshold]
  config[:critical_threshold].to_i
end

def warning_length
  unknown "No critical threshold specified" unless config[:warning_threshold]
  config[:warning_threshold].to_i
end

def current_queue_size
  Resque.size("#{v}")
end

def monitoring_queue
  print "Monitoring #{v} queue\n"
end

  if "#{current_queue_size}" >= "#{critical_length}"
    puts "Critical - Queue currently has #{current_queue_size} items\n"
    exit 2
  elsif "#{current_queue_size}" >= "#{warning_length}"
    puts "Warning - the queue is currently at #{current_queue_size}\n"
    exit 1
  else 
    puts "OK - The queue has #{current_queue_size} items"
    exit 0
  end
end
end
end