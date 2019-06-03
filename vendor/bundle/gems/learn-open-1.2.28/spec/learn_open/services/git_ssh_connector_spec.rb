require 'spec_helper'
require 'pry'

describe LearnOpen::GitSSHConnector do
  let(:git_server) { 'github.example.com' }
  let(:ssh_adapter_instance) { instance_double(LearnOpen::Adapters::SshAdapter) }
  let(:ssh_adapter) { class_double(LearnOpen::Adapters::SshAdapter) }
  let(:ssh_connector) { LearnOpen::GitSSHConnector.new(git_server: git_server, environment: environment) }
  let(:environment) { instance_double(LearnOpen::Environments::IDEEnvironment) }

  before do
    allow(LearnOpen).to receive(:ssh_adapter).and_return(ssh_adapter)
    allow(ssh_adapter).to receive(:new).with(user: 'git', hostname: git_server).and_return(ssh_adapter_instance)
  end

  context 'for an authenticated SSH connection' do
    before do
      allow(ssh_adapter_instance).to receive(:authenticated?).and_return(true)
      allow(environment).to receive(:managed?).and_return(true)
    end

    it 'does not attempt to upload keys' do
      expect(ssh_connector).to_not receive(:upload_ssh_keys!)
      ssh_connector.call
    end
  end

  context 'for an unauthenticated SSH connection' do
    before do
      allow(ssh_adapter_instance).to receive(:authenticated?).and_return(false)
    end

    context 'on a managed server' do
      before do
        allow(environment).to receive(:managed?).and_return(true)
      end

      it 'attempts to upload a key' do
        expect(ssh_connector).to receive(:upload_ssh_keys!).exactly(:once)
        ssh_connector.call
      end
    end

    context 'on an unmanaged server' do
      before do
        allow(environment).to receive(:managed?).and_return(false)
      end

      it 'does not attempt to upload a key' do
        expect(ssh_connector).to_not receive(:upload_ssh_keys!)
        ssh_connector.call
      end
    end
  end
end
