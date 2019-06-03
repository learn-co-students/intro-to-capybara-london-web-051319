module LearnOpen
  module Lessons
    class JupyterLesson < BaseLesson
      def self.detect(lesson)
        dot_learn = Hash(lesson.dot_learn)
        !!dot_learn[:jupyter_notebook]
      end

      def open(environment, editor, clone_only)
        environment.open_jupyter_lab(self, location, editor, clone_only)
      end
    end
  end
end
