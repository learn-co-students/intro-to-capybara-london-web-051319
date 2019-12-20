module LearnOpen
  module DependencyInstallers
    class BaseInstaller
      attr_reader :lesson, :location, :system_adapter, :io, :environment

      def self.call(lesson, location, environment, options)
        if self.detect(lesson, location)
          self.new(lesson, location, environment, options).run
        end
      end

      def initialize(lesson, location, environment, options)
        @lesson = lesson
        @location = location
        @environment = environment
        @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
        @io = options.fetch(:io, LearnOpen.default_io)
      end
    end
  end
end
