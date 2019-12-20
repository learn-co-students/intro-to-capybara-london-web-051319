module LearnOpen
  class GitSSHConnector
    attr_reader :ssh_connection, :environment

    GIT_SSH_USER = 'git'

    def self.call(git_server:, environment:)
      self.new(git_server: git_server, environment: environment).call
    end

    def initialize(git_server:, environment:)
      @ssh_connection = LearnOpen.ssh_adapter.new(user: GIT_SSH_USER, hostname: git_server)
      @environment = environment
    end

    def call
      if managed_environment? && ssh_unauthenticated?
        upload_ssh_keys!
      end

      ssh_authenticated?
    end

    def upload_ssh_keys!
      LearnOpen.learn_web_client.add_ssh_key(key: ssh_connection.public_key)
    end

    def managed_environment?
      environment.managed?
    end

    def ssh_unauthenticated?
      !ssh_authenticated?
    end

    def ssh_authenticated?
      ssh_connection.authenticated?
    end
  end
end
