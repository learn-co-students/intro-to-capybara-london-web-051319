module LearnOpen
  module Adapters
    class IOAdapter
      attr_reader :input, :output

      def initialize(input:, output:)
        @input = input
        @output = output
      end

      def puts(*message)
        output.puts(*message)
      end

      def print(*message)
        output.print(*message)
      end

      def gets
        input.gets
      end
    end
  end
end
