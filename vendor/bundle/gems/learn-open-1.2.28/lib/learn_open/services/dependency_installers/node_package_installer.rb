module LearnOpen
  module DependencyInstallers
    class NodeInstaller < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{lesson.to_path}/package.json")
      end

      def run
        io.puts 'Installing npm dependencies...'

        case environment
        when LearnOpen::Environments::IDEEnvironment
          system_adapter.run_command("yarn install --no-lockfile")
        else
          system_adapter.run_command("npm install")
        end
      end
    end
  end
end
