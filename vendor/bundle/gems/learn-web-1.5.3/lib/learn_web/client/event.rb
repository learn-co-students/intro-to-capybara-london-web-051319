require 'learn_web/client/event/submission'

module LearnWeb
  class Client
    module Event
      attr_reader :client

      IRONBROKER_URL = 'http://ironbroker-v2.flatironschool.com'

      def client
        @client ||= Faraday.new(url: IRONBROKER_URL) do |faraday|
          faraday.adapter Faraday.default_adapter
        end
      end

      def submission_endpoint
        '/e/learn_gem'
      end

      def submit_event(params)
        response = post(
          submission_endpoint,
          body: params,
          client: client
        )

        LearnWeb::Client::Event::Submission.new(response)
      end
    end
  end
end
