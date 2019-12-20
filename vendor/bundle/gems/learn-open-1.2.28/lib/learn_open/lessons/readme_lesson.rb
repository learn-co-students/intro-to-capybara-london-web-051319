module LearnOpen
  module Lessons
    class ReadmeLesson < BaseLesson
      def self.detect(lesson)
        !lesson.lab
      end

      def open(environment, _editor, _clone_only)
        environment.open_readme(self)
      end
    end
  end
end
