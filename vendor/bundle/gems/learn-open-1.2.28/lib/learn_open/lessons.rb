module LearnOpen
  module Lessons

    def self.default
      LabLesson
    end

    def self.lesson_types
      [
          JupyterLesson,
          ReadmeLesson,
          IosLesson,
      ]
    end

    def self.classify(lesson_data, options = {})
      lesson = lesson_data[:lesson]
      default = method(:default)
      lesson_types.find(default) do |type|
        type.detect(lesson)
      end.new(lesson_data, options)
    end
  end
end
