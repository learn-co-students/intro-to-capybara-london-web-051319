module LearnOpen
  module Adapters
    class SshAdapter
      attr_reader :user, :hostname

      SSH_AUTH_SUCCESS_EXIT_STATUS = 1
      SSH_AUTH_FAILURE_EXIT_STATUS = 255

      def initialize(user:, hostname:)
        @user = user
        @hostname = hostname
      end

      def public_key
        File.read("#{ENV['HOME']}/.ssh/id_rsa.pub").chomp
      end

      def unauthenticated?
        !authenticated?
      end

      def authenticated?
        _stdout, stderr, status = LearnOpen.system_adapter.run_command_with_capture("ssh -T #{user}@#{hostname}")

        case status.exitstatus
        when SSH_AUTH_SUCCESS_EXIT_STATUS
          true
        when SSH_AUTH_FAILURE_EXIT_STATUS
          case stderr
          when /permission denied/i
            false
          else
            raise LearnOpen::Adapters::SshAdapter::UnknownError
          end
        else
          raise LearnOpen::Adapters::SshAdapter::UnknownError
        end
      end

      class UnknownError < StandardError
      end
    end
  end
end
