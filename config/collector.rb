require "airbrake"
require_relative "../lib/insidegov_collector"
require_relative "../config/initializers/errbit"

module DataInsight
  module Collector
    def self.options
    {
        base_url: "insidegov base url"
    }
    end

    def self.collector(arguments)
      InsideGovCollector.new(arguments)
    end

    def self.queue_name(arguments)
      "datainsight"
    end

    def self.queue_routing_key(arguments)
      "inside_gov"
    end

    def self.handle_error(error)
      Airbrake.notify(error)
      true
    end

  end
end