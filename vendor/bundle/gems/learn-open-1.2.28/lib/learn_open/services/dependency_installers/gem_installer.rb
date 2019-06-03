module LearnOpen
  module DependencyInstallers
    class GemInstaller < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{lesson.to_path}/Gemfile")
      end

      def run
        io.puts "Bundling..."
        system_adapter.run_command("bundle install")
      end
    end
  end
end
