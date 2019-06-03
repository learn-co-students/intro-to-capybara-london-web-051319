module LearnOpen
  module Lessons
    class IosLesson < BaseLesson
      def self.detect(lesson)
        languages = Hash(lesson.dot_learn)[:languages]
        (languages & ["swift", "objc"]).any?
      end

      def open(environment, editor, clone_only)
        environment.open_lab(self, location, editor, clone_only)
      end
    end
  end
end
