require 'spec_helper'

describe LearnOpen::Adapters::SshAdapter do
  describe '#authenticated?' do
    let(:status) { double() }
    let(:ssh_adapter) { LearnOpen::Adapters::SshAdapter.new(user: 'foo', hostname: 'bar') }

    it 'returns true on success' do
      allow(status).to receive(:exitstatus).and_return(LearnOpen::Adapters::SshAdapter::SSH_AUTH_SUCCESS_EXIT_STATUS)
      allow(LearnOpen.system_adapter).to receive(:run_command_with_capture).and_return(['', '', status])
      expect(ssh_adapter.authenticated?).to be true
    end

    it 'return false when permission denied' do
      allow(status).to receive(:exitstatus).and_return(LearnOpen::Adapters::SshAdapter::SSH_AUTH_FAILURE_EXIT_STATUS)
      allow(LearnOpen.system_adapter).to receive(:run_command_with_capture).and_return(['', 'permission denied', status])
      expect(ssh_adapter.authenticated?).to be false
    end

    it 'raises an unknown error for failures that arent permission denied' do
      allow(status).to receive(:exitstatus).and_return(LearnOpen::Adapters::SshAdapter::SSH_AUTH_FAILURE_EXIT_STATUS)
      allow(LearnOpen.system_adapter).to receive(:run_command_with_capture).and_return(['', 'core meltdown', status])
      expect{ssh_adapter.authenticated?}.to raise_error LearnOpen::Adapters::SshAdapter::UnknownError
    end

    it 'raises an unknown error for other exit statuses' do
      allow(status).to receive(:exitstatus).and_return(1337)
      allow(LearnOpen.system_adapter).to receive(:run_command_with_capture).and_return(['', 'alien abduction', status])
      expect{ssh_adapter.authenticated?}.to raise_error LearnOpen::Adapters::SshAdapter::UnknownError
    end
  end
end
