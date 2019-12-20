module LearnWeb
  class Client
    module Lesson
      class NextLesson
        attr_reader   :response
        attr_accessor :data, :id, :title, :link, :github_repo, :forked_repo,
                      :clone_repo, :assessments, :lab, :dot_learn

        include LearnWeb::AttributePopulatable
        include LearnWeb::ResponseParsable

        def initialize(response)
          @response = response

          parse!
        end
      end
    end
  end
end
