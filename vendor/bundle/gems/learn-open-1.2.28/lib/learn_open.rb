require 'yaml'
require 'netrc'
require 'git'
require 'learn_web'
require 'timeout'
require 'json'

require 'learn_open/version'
require 'learn_open/opener'
require 'learn_open/argument_parser'
require 'learn_open/adapters/system_adapter'
require 'learn_open/adapters/learn_web_adapter'
require 'learn_open/adapters/io_adapter'
require 'learn_open/adapters/ssh_adapter'
require 'learn_open/environments'
require 'learn_open/environments/base_environment'
require 'learn_open/environments/mac_environment'
require 'learn_open/environments/linux_environment'
require 'learn_open/environments/generic_environment'
require 'learn_open/environments/ide_environment'
require 'learn_open/environments/jupyter_container_environment'
require 'learn_open/services/dependency_installers'
require 'learn_open/services/dependency_installers/base_installer'
require 'learn_open/services/dependency_installers/gem_installer'
require 'learn_open/services/dependency_installers/jupyter_pip_installer'
require 'learn_open/services/dependency_installers/node_package_installer'
require 'learn_open/services/dependency_installers/pip_installer'
require 'learn_open/services/lesson_downloader'
require 'learn_open/services/file_backup_starter'
require 'learn_open/services/logger'
require 'learn_open/services/git_ssh_connector'
require 'learn_open/lessons'
require 'learn_open/lessons/base_lesson'
require 'learn_open/lessons/jupyter_lesson'
require 'learn_open/lessons/readme_lesson'
require 'learn_open/lessons/ios_lesson'
require 'learn_open/lessons/lab_lesson'

module LearnOpen
  def self.learn_web_client
    @client ||= begin
      _login, token = Netrc.read['learn-config']
      LearnWeb::Client.new(token: token)
    end
  end

  def self.logger
    @logger ||= begin
      home_dir = File.expand_path("~")
      Logger.new("#{home_dir}/.learn-open-tmp")
    end
  end

  def self.default_io
    LearnOpen::Adapters::IOAdapter.new(input: STDIN, output: Kernel)
  end

  def self.git_adapter
    Git
  end

  def self.environment_vars
    ENV
  end

  def self.ssh_adapter
    LearnOpen::Adapters::SshAdapter
  end

  def self.system_adapter
    LearnOpen::Adapters::SystemAdapter
  end

  def self.platform
    RbConfig::CONFIG['host_os']
  end

  def self.git_ssh_connector
    LearnOpen::GitSSHConnector
  end

  def self.lessons_directory
    @lesson_directory ||= begin
      home_dir = File.expand_path("~")
      YAML.load(File.read("#{home_dir}/.learn-config"))[:learn_directory]
    end
  end
end
