require 'spec_helper'

describe LearnOpen::LessonDownloader do
  let(:lesson)   { double(use_student_fork: true) }
  let(:location) { double }
  let(:environment) { double }
  let(:downloader) { LearnOpen::LessonDownloader.new(lesson, location, environment) }

  context 'downloaded lesson' do
    before do
      allow(downloader).to receive(:repo_exists?).and_return(true)
    end

    context 'able to make an SSH connection' do
      before do
        allow(downloader).to receive(:ensure_git_ssh!).and_return(true)
        allow(downloader).to receive(:fork_repo)
        allow(downloader).to receive(:clone_repo)
      end

      it 'returns status :noop' do
        expect(downloader.call).to eq :noop
      end
    end
  end

  context 'undownloaded lesson' do
    before do
      allow(downloader).to receive(:repo_exists?).and_return(false)
    end

    context 'able to make an SSH connection' do
      before do
        allow(downloader).to receive(:ensure_git_ssh!).and_return(true)
        allow(downloader).to receive(:fork_repo)
        allow(downloader).to receive(:clone_repo)
      end

      it 'forks the repo' do
        expect(downloader).to receive(:fork_repo)
        downloader.call
      end

      it 'clones the repo' do
        expect(downloader).to receive(:clone_repo)
        downloader.call
      end
    end

    context 'unable to make an SSH connection' do
      before do
        allow(downloader).to receive(:ensure_git_ssh!).and_return(false)
      end

      it 'returns status :ssh_unauthenticated' do
        expect(downloader.call).to eq :ssh_unauthenticated
      end
    end
  end
end
