module LearnOpen
  module Environments
    class GenericEnvironment < BaseEnvironment
      def open_readme(_lesson)
        io.puts "It looks like this lesson is a Readme. Please open it in your browser."
      end
    end
  end
end
