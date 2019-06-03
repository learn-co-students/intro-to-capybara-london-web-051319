module LearnOpen
  module DependencyInstallers
    def self.installer_types
      [
          PipInstaller,
          GemInstaller,
          NodeInstaller
      ]
    end

    def self.run_installers(lesson, location, environment, options)
      installer_types.each do |type|
        if type.detect(lesson, location)
          type.call(lesson, location, environment, options)
        end
      end
    end
  end
end
