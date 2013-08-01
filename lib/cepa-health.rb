# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

module CepaHealth
  attr_accessor :success

  # Container that holds the result of the probe execution
  class Result
    attr_reader :records

    def execute(name, block)
      @success &&= v = instance_exec(&block)
      record(name, v, v ? "Success" : "Failed")
    end

    def initialize
      @records = []
      @success = true
    end

    def record(name, status, comment)
      @records << [name, status, comment]
    end

    def success?
      @success
    end

  end

  class << self
    attr_reader :probes

    # Executes the probes.
    # @param [ Array<String> ] filters to the given levels when the probes
    # were registered. If no filters are specified, all probes are resulted.
    def execute(*filters)
      result = CepaHealth::Result.new
      filters = filters.map { |v| v.to_s }
      selected = filters.empty? ? probes : probes.select { |k,v| filters.include?(k) } 
      selected.values.flatten(1).each { |v| result.execute(*v) }
      result
    end

    # Loads an individual probe
    def load_probe(name)
      dir = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)), '..', 'probes'))
      Dir[File.join(dir, name)].each { |v| require(v) }
    end

    # Scans the probes directory for Ruby files.
    def load_probes
      dir = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)), '..', 'probes'))
      Dir[File.join(dir, "**/*.rb")].each { |v| require(v) }
    end

    # Registers the given block as a probe. An optional level can be supplied,
    # which can be used as a filter.
    def register(name, level = :error, &block)
      list = probes[level.to_s] ||= []
      list << [name, block]
      self
    end

  end
  @probes = {}

end

require "cepa-health/middleware"
require "cepa-health/version"

# Railtie to add the Middleware Automatically
if defined?(Rails)
  require 'cepa-health/generator'
  require 'cepa-health/railtie'
end
