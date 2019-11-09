module Depdump
  module Configurable
    def self.included(base)
      base.extend(ClassMethods)
      base.config
    end

    def config
      self.class.config
    end

    module ClassMethods
      def configure
        yield config
      end

      def config
        @config ||= Configuration.new
      end
    end

    class Configuration
      attr_accessor :output
      attr_reader :formatter

      def initialize
        @output = $stdout
        @format = Depdump::DependencyGraph::Formatter::Json.new
      end

      def formatter=(type)
        @formatter =
          case type
          when "json"
            Depdump::DependencyGraph::Formatter::Json.new
          when "table"
            Depdump::DependencyGraph::Formatter::Table.new
          else
            raise "Unknow format: #{type}"
          end
      end
    end
  end
end
