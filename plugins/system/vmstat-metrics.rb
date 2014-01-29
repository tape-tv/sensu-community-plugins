#!/usr/bin/env ruby
#
# System VMStat Plugin
# ===
#
# This plugin uses vmstat to collect basic system metrics, produces
# Graphite formated output.
#
# Copyright 2011 Sonian, Inc <chefs@sonian.net>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.
#
# rubocop:disable HandleExceptions

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'socket'

class VMStat < Sensu::Plugin::Metric::CLI::Graphite

  option :scheme,
    :description => "Metric naming scheme, text to prepend to .$parent.$child",
    :long => "--scheme SCHEME",
    :default => "system.#{Socket.gethostname}.vmstat"

  def convert_integers(values)
    values.each_with_index do |value, index|
      begin
        converted = Integer(value)
        values[index] = converted
      rescue ArgumentError
      end
    end
    values
  end

  def run
    result = convert_integers(`vmstat 1 2|tail -n1`.split(" "))
    timestamp = Time.now.to_i
    metrics = {
       :cpu => {
         :user => result[12],
         :system => result[13],
         :idle => result[14],
         :waiting => result[15]
      }
    }
    metrics.each do |parent, children|
      children.each do |child, value|
        output [config[:scheme], parent, child].join("."), value, timestamp
      end
    end
    ok
  end

end
