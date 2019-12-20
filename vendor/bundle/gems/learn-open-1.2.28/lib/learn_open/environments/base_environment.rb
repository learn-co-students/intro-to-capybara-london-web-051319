module LearnOpen
  module Environments
    class BaseEnvironment

      attr_reader :io, :environment_vars, :system_adapter, :options, :logger

      def initialize(options={})
        @io = options.fetch(:io) { LearnOpen.default_io }
        @environment_vars = options.fetch(:environment_vars) { LearnOpen.environment_vars }
        @system_adapter = options.fetch(:system_adapter) { LearnOpen.system_adapter }
        @logger = options.fetch(:logger) { LearnOpen.logger }
        @options = options
      end

      def managed?
        false
      end

      def open_jupyter_lab(_lesson, _location, _editor, _clone_only)
        :noop
      end

      def open_lab(lesson, location, editor, clone_only)
        case lesson
        when LearnOpen::Lessons::IosLesson
          io.puts "You need to be on a Mac to work on iOS lessons."
        else
          case download_lesson(lesson, location)
          when :ok, :noop
            open_editor(lesson, location, editor) unless clone_only
            install_dependencies(lesson, location)
            notify_of_completion
            open_shell unless clone_only
          when :ssh_unauthenticated
            io.puts 'Failed to obtain an SSH connection!'
          else
            raise LearnOpen::Environments::UnknownLessonDownloadError
          end
        end
      end

      def install_dependencies(lesson, location)
        DependencyInstallers.run_installers(lesson, location, self, options)
      end

      def download_lesson(lesson, location)
        LessonDownloader.call(lesson, location, self, options)
      end

      def open_editor(lesson, location, editor)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory(lesson.to_path)
        system_adapter.open_editor(editor, path: ".")
      end

      def start_file_backup(lesson, location)
        FileBackupStarter.call(lesson, location, options)
      end

      def open_shell
        system_adapter.open_login_shell(environment_vars['SHELL'])
      end

      def notify_of_completion
        logger.log("Done.")
        io.puts "Done."
      end
    end
  end
end
