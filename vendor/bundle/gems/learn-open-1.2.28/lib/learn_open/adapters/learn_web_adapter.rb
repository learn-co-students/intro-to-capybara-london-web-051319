module LearnOpen
  module Adapters
    class LearnWebAdapter
      attr_reader :client, :io

      def initialize(options = {})
        @client = options.fetch(:learn_web_client) {LearnOpen.learn_web_client}
        @io = options.fetch(:io) {LearnOpen.default_io}
      end

      def fetch_lesson_data(target_lesson: false, fetch_next_lesson: false)
        if opening_current_lesson?(target_lesson, fetch_next_lesson)
          load_current_lesson
          {
              lesson: current_lesson,
              id: current_lesson.id,
              later_lesson: false
          }
        elsif opening_next_lesson?(target_lesson, fetch_next_lesson)
          load_next_lesson
          {
              lesson: next_lesson,
              id: next_lesson.id,
              later_lesson: false
          }
        else
          lesson = get_lesson(target_lesson)
          {
              lesson: lesson,
              id: lesson.lesson_id,
              later_lesson: lesson.later_lesson
          }
        end
      end

      def opening_current_lesson?(target_lesson, fetch_next_lesson)
        !target_lesson && !fetch_next_lesson
      end

      def opening_next_lesson?(target_lesson, fetch_next_lesson)
        !target_lesson && fetch_next_lesson
      end

      def current_lesson
        @current_lesson ||= client.current_lesson
      end

      def next_lesson
        @next_lesson ||= client.next_lesson
      end

      def load_current_lesson(retries = 3)
        begin
          Timeout::timeout(15) do
            current_lesson
          end
        rescue Timeout::Error
          if retries > 0
            io.puts "There was a problem getting your lesson from Learn. Retrying..."
            load_current_lesson(retries - 1)
          else
            io.puts "There seems to be a problem connecting to Learn. Please try again."
            logger.log('ERROR: Error connecting to Learn')
            exit
          end
        end
      end

      def load_next_lesson(retries = 3)
        begin
          Timeout::timeout(15) do
            next_lesson
          end
        rescue Timeout::Error
          if retries > 0
            io.puts "There was a problem getting your next lesson from Learn. Retrying..."
            load_next_lesson(retries - 1)
          else
            io.puts "There seems to be a problem connecting to Learn. Please try again."
            logger.log('ERROR: Error connecting to Learn')
            exit
          end
        end
      end

      def get_lesson(target_lesson, retries = 3)
        @correct_lesson ||= begin
          Timeout::timeout(15) do
            client.validate_repo_slug(repo_slug: target_lesson)
          end
        rescue Timeout::Error
          if retries > 0
            io.puts "There was a problem connecting to Learn. Retrying..."
            get_lesson(target_lesson, retries - 1)
          else
            io.puts "Cannot connect to Learn right now. Please try again."
            logger.log('ERROR: Error connecting to Learn')
            exit
          end
        end
      end
    end
  end
end
