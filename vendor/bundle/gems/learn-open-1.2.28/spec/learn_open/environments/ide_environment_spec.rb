require 'spec_helper'
require 'fakefs/spec_helpers'

describe LearnOpen::Environments::IDEEnvironment do
  include FakeFS::SpecHelpers
  subject { LearnOpen::Environments::IDEEnvironment }

  let(:io) { instance_double(LearnOpen::Adapters::IOAdapter) }

  before do
    allow(LearnOpen::GitSSHConnector)
      .to receive(:call)
      .with(git_server: instance_of(String), environment: instance_of(LearnOpen::Environments::IDEEnvironment))
      .and_return(true)
  end

  context "Invalid environment" do
    before do
      @home_dir = create_linux_home_dir("bobby")

      expect(io)
        .to receive(:puts)
        .with("Opening new window")
    end

    let(:lesson) { double(name: "a-different-lesson") }
    let(:env_vars) {{ "LAB_NAME" => "correct_lab", "CREATED_USER" => "bobby" }}
    let(:environment) { subject.new({ io: io, environment_vars: env_vars, logger: spy }) }

    it "opens correct readme" do
      environment.open_readme(lesson)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"open_lab","lab_name":"a-different-lesson"}\n})
    end

    it "opens correct lab" do
      environment.open_lab(lesson, double, double, false)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"open_lab","lab_name":"a-different-lesson"}\n})
    end

    it "opens correct jupyter lab" do
      environment.open_jupyter_lab(lesson, double, double, false)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"open_lab","lab_name":"a-different-lesson"}\n})
    end
  end

  context "valid environments" do
    before do
      @home_dir = create_linux_home_dir("bobby")
    end

    let(:lesson) do
      double(
        name: "valid_lab",
        later_lesson: false,
        to_url: "valid-lesson-url",
        to_path: @home_dir,
        git_server: "github.com",
        repo_path: "/org/lesson",
        use_student_fork: true
      )
    end

    let(:deployed_source_lesson) do
      double(
        name: "valid_lab",
        later_lesson: false,
        to_url: "valid-lesson-url",
        to_path: @home_dir,
        git_server: "github.com",
        repo_path: "/org/lesson",
        use_student_fork: false
      )
    end

    let(:env_vars) {{ "LAB_NAME" => "valid_lab", "CREATED_USER" => "bobby", "SHELL" => "/usr/local/fish"}}
    let(:git_adapter) { double }
    let(:system_adapter) { double }
    let(:git_ssh_connector) { double(call: true) }
    let(:environment) do
      subject.new({
          io: io,
          environment_vars: env_vars,
          logger: spy,
          git_adapter: git_adapter,
          system_adapter: system_adapter,
          git_ssh_connector: git_ssh_connector
        })
    end

    it "opens the readme in the browser" do
      expect(io).to receive(:puts).with("Opening readme...")
      environment.open_readme(lesson)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"browser_open","url":"valid-lesson-url"}\n})
    end
    it "opens the lab" do
      location = double
      editor = "vim"
      clone_only = false

      expect(io).to receive(:puts).with("Forking lesson...")
      expect(io).to receive(:puts).with("Cloning lesson...")
      expect(io).to receive(:puts).with("Opening lesson...")
      expect(io).to receive(:puts).with("Done.")
      expect(git_adapter)
        .to receive(:clone)
        .with("git@github.com:/org/lesson.git", "valid_lab", {:path=> location})
      expect(system_adapter)
        .to receive(:change_context_directory)
        .with("/home/bobby")
      expect(system_adapter)
        .to receive(:open_editor)
        .with("vim", {:path=>"."})
      expect(system_adapter)
        .to receive(:spawn)
        .with("restore-lab", {:block=>true})
      expect(system_adapter)
        .to receive(:spawn)
        .with(LearnOpen::FileBackupStarter::BACKUP_LAB_PROCESS)
      expect(system_adapter)
        .to receive(:open_login_shell)
        .with("/usr/local/fish")

      environment.open_lab(lesson, location, editor, clone_only)
    end
  end
end
