module LearnOpen
  class Opener
    attr_reader :editor,
                :target_lesson,
                :get_next_lesson,
                :clone_only,
                :io,
                :logger,
                :options

    def self.run(lesson:, editor_specified:, get_next_lesson:, clone_only:)
      new(lesson, editor_specified, get_next_lesson, clone_only).run
    end

    def initialize(target_lesson, editor, get_next_lesson, clone_only, options = {})
      @target_lesson = target_lesson
      @editor = editor
      @get_next_lesson = get_next_lesson
      @clone_only = clone_only

      @io = options.fetch(:io, LearnOpen.default_io)
      @logger = options.fetch(:logger, LearnOpen.logger)

      @options = options
    end

    def run
      logger.log('Getting lesson...')
      io.puts "Looking for lesson..."

      lesson_data = LearnOpen::Adapters::LearnWebAdapter
                        .new(options)
                        .fetch_lesson_data(
                            target_lesson: target_lesson,
                            fetch_next_lesson: get_next_lesson
                        )

      lesson = Lessons.classify(lesson_data, options)
      environment = LearnOpen::Environments.classify(options)
      lesson.open(environment, editor, clone_only)
    end
  end
end
