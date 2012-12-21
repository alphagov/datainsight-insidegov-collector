require "airbrake"

module DataInsight
  module Collector
    def self.options
    {
        do_all_the_stuff: "okay"
    }
    end

    def self.collector(arguments)
      #return some collector
      collector = {}
    end

    def self.queue_name(arguments)
      "datainsight"
    end

    def self.queue_routing_key(arguments)
      "inside_gov"
    end

    def self.handle_error(error)
      Airbrake.notify(error)
    end

  end
end