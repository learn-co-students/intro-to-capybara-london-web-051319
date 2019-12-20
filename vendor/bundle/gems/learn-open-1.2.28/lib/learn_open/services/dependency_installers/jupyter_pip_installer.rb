module LearnOpen
  module DependencyInstallers
    class JupyterPipInstall < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{lesson.to_path}/requirements.txt")
      end

      def run
        io.puts "Installing pip dependencies..."
        system_adapter.run_command("/opt/conda/bin/python -m pip install -r requirements.txt")
      end
    end
  end
end
