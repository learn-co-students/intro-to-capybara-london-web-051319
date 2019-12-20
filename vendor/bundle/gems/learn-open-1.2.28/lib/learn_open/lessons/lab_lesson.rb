module LearnOpen
  module Lessons
    class LabLesson < BaseLesson
      def open(environment, editor, clone_only)
        environment.open_lab(self, location, editor, clone_only)
      end
    end
  end
end
