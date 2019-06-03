module LearnOpen
  module Environments
    class JupyterContainerEnvironment < BaseEnvironment
      def managed?
        true
      end

      def open_jupyter_lab(lesson, location, editor, clone_only)
        download_lesson(lesson, location)
        start_file_backup(lesson, location) if lesson.use_student_fork
        install_jupyter_dependencies(lesson, location)
        notify_of_completion
        open_shell unless clone_only
      end

      def open_editor(lesson, location, editor)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory(lesson.to_path)
        system_adapter.open_editor(editor, path: ".")
      end

      def install_jupyter_dependencies(lesson, location)
        LearnOpen::DependencyInstallers::JupyterPipInstall.call(lesson, location, self, options)
      end
    end
  end
end
