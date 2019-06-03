module LearnWeb
  class Client
    module SshKeys
      class Add
        attr_reader :response
        attr_accessor :data

        include LearnWeb::AttributePopulatable

        def initialize(response)
          @response = response
        end

        def parse!
          if response.status == 200
            self.data = Oj.load(response.body, symbol_keys: true)

            populate_attributes!
            self
          else
            case response.status
            when 304
              puts "This key is already in use."
            when 422
              puts "Something went wrong. Please try again."
            else
              puts "Something went wrong. Please try again."
            end
            :error
          end
        end
      end
    end
  end
end
