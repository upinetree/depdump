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

      def initialize
        @output = $stdout
      end
    end
  end
end
