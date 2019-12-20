module LearnOpen
  module Lessons
    class BaseLesson
      attr_reader :repo_path,
                  :organization,
                  :name,
                  :id,
                  :dot_learn,
                  :git_server,
                  :later_lesson,
                  :use_student_fork,
                  :options,
                  :io,
                  :system_adapter,
                  :platform,
                  :environment_vars,
                  :logger,
                  :location

      def initialize(lesson_data, options = {})
        lesson = lesson_data[:lesson]

        @repo_path = lesson.clone_repo
        @organization, @name = repo_path.split('/')

        @git_server = lesson.git_server
        @dot_learn = lesson.dot_learn
        @is_lab = lesson.lab
        @use_student_fork = lesson.use_student_fork
        @later_lesson = lesson_data[:later_lesson]
        @id = lesson_data[:id]

        @logger = options.fetch(:logger, LearnOpen.logger)
        @io = options.fetch(:io, LearnOpen.default_io)
        @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
        @platform = options.fetch(:platform, LearnOpen.platform)
        @environment_vars = options.fetch(:environment_vars, LearnOpen.environment_vars)
        @location = options.fetch(:lessons_directory) {LearnOpen.lessons_directory}
        @options = options
      end

      def lab?
        @is_lab
      end

      def readme?
        !lab?
      end

      def to_path
        "#{location}/#{name}"
      end

      def to_url
        "https://learn.co/lessons/#{id}"
      end
    end
  end
end
