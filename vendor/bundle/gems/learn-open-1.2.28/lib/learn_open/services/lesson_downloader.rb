module LearnOpen
  class LessonDownloader
    attr_reader :lesson, :location, :environment, :io, :logger, :client, :git_adapter, :git_ssh_connector

    def self.call(lesson, location, environment, options = {})
      self.new(lesson, location, environment, options).call
    end

    def initialize(lesson, location, environment, options = {})
      @lesson = lesson
      @location = location
      @environment = environment
      @client = options.fetch(:learn_web_client) { LearnOpen.learn_web_client }
      @logger = options.fetch(:logger) { LearnOpen.logger }
      @io = options.fetch(:io) { LearnOpen.default_io }
      @git_adapter = options.fetch(:git_adapter) { LearnOpen.git_adapter }
      @git_ssh_connector = options.fetch(:git_ssh_connector) { LearnOpen.git_ssh_connector }
    end

    def call
      if !repo_exists?
        if ensure_git_ssh!
          fork_repo if lesson.use_student_fork
          clone_repo
          :ok
        else
          :ssh_unauthenticated
        end
      else
        :noop
      end
    end

    def ensure_git_ssh!
      git_ssh_connector.call(git_server: lesson.git_server, environment: environment)
    end

    def fork_repo(retries = 3)
      logger.log('Forking repository...')
      io.puts "Forking lesson..."

      begin
        Timeout::timeout(15) do
          client.fork_repo(repo_name: lesson.name)
        end
      rescue Timeout::Error
        if retries > 0
          io.puts "There was a problem forking this lesson. Retrying..."
          fork_repo(retries - 1)
        else
          io.puts "There is an issue connecting to Learn. Please try again."
          logger.log('ERROR: Error connecting to Learn')
          exit
        end
      end

    end

    def clone_repo(retries = 3)
      logger.log('Cloning to your machine...')
      io.puts "Cloning lesson..."
      begin
        Timeout::timeout(15) do
          git_adapter.clone("git@#{lesson.git_server}:#{lesson.repo_path}.git", lesson.name, path: location)
        end
      rescue Git::GitExecuteError
        if retries > 0
          io.puts "There was a problem cloning this lesson. Retrying..." if retries > 1
          sleep(1)
          clone_repo(retries - 1)
        else
          io.puts "Cannot clone this lesson right now. Please try again."
          logger.log('ERROR: Error cloning. Try again.')
          exit
        end
      rescue Timeout::Error
        if retries > 0
          io.puts "There was a problem cloning this lesson. Retrying..."
          clone_repo(retries - 1)
        else
          io.puts "Cannot clone this lesson right now. Please try again."
          logger.log('ERROR: Error cloning. Try again.')
          exit
        end
      end

    end

    def repo_exists?
      File.exists?("#{lesson.to_path}/.git")
    end
  end
end
