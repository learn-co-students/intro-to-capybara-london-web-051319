module LearnOpen
  module Environments
    class LinuxEnvironment < BaseEnvironment
      def open_readme(lesson)
        io.puts "Opening readme..."
        system_adapter.run_command("xdg-open #{lesson.to_url}")
      end

      def open_jupyter_lab(lesson, location, _editor, _clone_only)
        io.puts "Opening Jupyter Lesson..."
        system_adapter.run_command("xdg-open #{lesson.to_url}")
      end
    end
  end
end
