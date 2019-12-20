require 'spec_helper'
require 'fakefs/spec_helpers'
require 'pry'

describe LearnOpen::Opener do
  include FakeFS::SpecHelpers
  let(:learn_web_client)       { FakeLearnClient.new(token: "some-amazing-password") }
  let(:git_adapter)            { FakeGit.new }
  let(:system_adapter)         { class_double(LearnOpen::Adapters::SystemAdapter) }
  let(:git_ssh_connector)      { class_double(LearnOpen::GitSSHConnector) }

  before do
    create_home_dir
    create_netrc_file
    create_learn_config_file

    allow(git_ssh_connector)
      .to receive(:call)
      .with(git_server: instance_of(String), environment: anything)
      .and_return(true)
  end

  context "Initializer" do
    it "sets the lesson" do
      opener = LearnOpen::Opener.new("ttt-2-board-rb-v-000","", false, false)
      expect(opener.target_lesson).to eq("ttt-2-board-rb-v-000")
    end
    it "sets the editor" do
      opener = LearnOpen::Opener.new("", "atom", false, false)
      expect(opener.editor).to eq("atom")
    end
    it "sets the whether to open the next lesson or not" do
      opener = LearnOpen::Opener.new("", "", true, false)
      expect(opener.get_next_lesson).to eq(true)
    end

    it "sets the clone only options" do
      opener = LearnOpen::Opener.new("", "", true, true)
      expect(opener.clone_only).to eq(true)
    end
  end

  context "running the opener" do
    it "calls its collaborators" do
      clone_only = false
      expect(system_adapter)
        .to receive(:open_editor)
        .with("atom", path: ".")

      expect(system_adapter)
        .to receive(:open_login_shell)
        .with("/usr/local/bin/fish")

      expect(system_adapter)
        .to receive(:change_context_directory)
        .with("/home/bobby/Development/code/rails-dynamic-request-lab-cb-000")

      expect(learn_web_client)
        .to receive(:fork_repo)
        .with(repo_name: "rails-dynamic-request-lab-cb-000")

      expect(git_ssh_connector)
        .to receive(:call)

      opener = LearnOpen::Opener.new(nil, "atom", true, clone_only,
                                     learn_web_client: learn_web_client,
                                     git_adapter: git_adapter,
                                     environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter,
                                     git_ssh_connector: git_ssh_connector,
                                     io: spy)
      opener.run
    end
  end

  context "clone_only" do
    it "It only calls clone/fork code, but doesn't open shell" do
      clone_only = true

      expect(learn_web_client)
        .to receive(:fork_repo)
        .with(repo_name: "rails-dynamic-request-lab-cb-000")

      expect(git_ssh_connector)
        .to receive(:call)

      opener = LearnOpen::Opener.new(nil, "atom", true, clone_only,
                                     learn_web_client: learn_web_client,
                                     git_adapter: git_adapter,
                                     environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter,
                                     git_ssh_connector: git_ssh_connector,
                                     io: spy)
      opener.run
    end
  end

  context "Opening on specific environments" do
    before do
      allow(system_adapter).to receive_messages(
        open_editor: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop
      )
      allow(learn_web_client).to receive(:fork_repo)
    end
    context "IDE" do
      it "restores files and watches for changes" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "ruby_lab",
          "CREATED_USER" => "bobby",
          "IDE_CONTAINER" => "true",
          "IDE_VERSION" => "3"
        }

        create_linux_home_dir("bobby")
        expect(system_adapter)
          .to receive(:spawn)
          .with('restore-lab', block: true)
        expect(system_adapter)
          .to receive(:spawn)
          .with(LearnOpen::FileBackupStarter::BACKUP_LAB_PROCESS)
        expect(system_adapter)
          .to receive(:run_command)
          .with("bundle install")

        opener = LearnOpen::Opener.new("ruby_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: spy)
        opener.run
      end
      it "does not write to the custom commands log if environment is for intended lab" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "rails-dynamic-request-lab-cb-000",
          "CREATED_USER" => "bobby",
          "IDE_CONTAINER" => "true",
          "IDE_VERSION" => "3"
        }
        allow(system_adapter).to receive_messages([:spawn, :spawn])

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: spy)
        opener.run
        expect(File.exist?("#{home_dir}/.custom_commands.log")).to eq(false)
      end

      it "writes to custom_commands_log if lab name doesn't match env" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "Something wild",
          "CREATED_USER" => "bobby",
          "IDE_CONTAINER" => "true",
          "IDE_VERSION" => "3"
        }
        allow(system_adapter).to receive_messages([:spawn, :spawn])

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: spy)
        opener.run
        custom_commands_log = File.read("#{home_dir}/.custom_commands.log")
        expect(custom_commands_log).to eq("{\"command\":\"open_lab\",\"lab_name\":\"rails-dynamic-request-lab-cb-000\"}\n")
      end

      it "writes to custom_commands_log if only if it's IDE" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "Something wild",
          "CREATED_USER" => "bobby"
        }
        allow(system_adapter).to receive_messages([:spawn, :spawn])

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: spy)
        opener.run
        expect(File.exist?("#{home_dir}/.custom_commands.log")).to eq(false)
      end

      it "runs yarn install if lab is a node lab" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "node_lab",
          "CREATED_USER" => "bobby",
          "IDE_CONTAINER" => "true",
        }
        allow(system_adapter).to receive_messages([:spawn, :spawn])
        expect(system_adapter)
          .to receive(:open_editor)
          .with("atom", path: ".")

        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")

        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/node_lab")

        expect(system_adapter)
          .to receive(:run_command)
          .with("yarn install --no-lockfile")

        opener = LearnOpen::Opener.new("node_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: spy)
        opener.run
      end
    end
  end
  context "Logging" do
    let(:environment) {{ "SHELL" => "/usr/local/bin/fish", "JUPYTER_CONTAINER" => "true" }}

    it "logs if an SSH connection cannot be made" do
      allow(LearnOpen::LessonDownloader).to receive(:call).and_return(:ssh_unauthenticated)

      allow(system_adapter).to receive_messages(
        open_editor: :noop,
        spawn: :noop,
        spawn: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop,
        run_command: :noop,
      )

      io = StringIO.new

      opener = LearnOpen::Opener.new("ruby_lab", "atom", false, false,
                                     learn_web_client: learn_web_client,
                                     git_adapter: git_adapter,
                                     environment_vars: environment,
                                     system_adapter: system_adapter,
                                     io: io)
      opener.run
      io.rewind
      expect(io.read).to eq(<<-EOF)
Looking for lesson...
Failed to obtain an SSH connection!
      EOF
    end

    it "prints the right things" do
      allow(learn_web_client).to receive(:fork_repo)

      allow(git_adapter).to receive(:clone).and_call_original

      allow(system_adapter).to receive_messages(
        open_editor: :noop,
        spawn: :noop,
        spawn: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop,
        run_command: :noop,
      )

      io = StringIO.new

      opener = LearnOpen::Opener.new("jupyter_lab", "atom", false, false,
                                     learn_web_client: learn_web_client,
                                     git_adapter: git_adapter,
                                     environment_vars: environment,
                                     system_adapter: system_adapter,
                                     git_ssh_connector: git_ssh_connector,
                                     io: io)
      opener.run
      io.rewind
      expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Installing pip dependencies...
Done.
      EOF
    end

    it "logs final status in file" do
      allow(learn_web_client).to receive(:fork_repo)

      allow(git_adapter).to receive(:clone).and_call_original

      allow(system_adapter).to receive_messages(
        open_editor: :noop,
        spawn: :noop,
        spawn: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop,
        run_command: :noop,
      )


      opener = LearnOpen::Opener.new("jupyter_lab", "atom", false, false,
                                     learn_web_client: learn_web_client,
                                     git_adapter: git_adapter,
                                     environment_vars: environment,
                                     system_adapter: system_adapter,
                                     git_ssh_connector: git_ssh_connector,
                                     io: spy)
      opener.run
      expect(File.read("#{home_dir}/.learn-open-tmp")).to eq("Done.")
    end
  end
  context "Lab Types" do
    context "Jupyter Labs" do
      it "correctly opens jupyter lab on jupyter container" do
        environment = { "SHELL" => "/usr/local/bin/fish", "JUPYTER_CONTAINER" => "true" }
        expect(learn_web_client)
          .to receive(:fork_repo)
          .with(repo_name: "jupyter_lab")

        expect(git_adapter)
          .to receive(:clone)
          .with("git@github.com:StevenNunez/jupyter_lab.git", "jupyter_lab", {:path=>"/home/bobby/Development/code"})
          .and_call_original

        expect(system_adapter)
          .to receive(:spawn)
          .with("restore-lab", block: true)
        expect(system_adapter)
          .to receive(:spawn)
          .with(LearnOpen::FileBackupStarter::BACKUP_LAB_PROCESS)
        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")
        expect(system_adapter)
          .to receive(:run_command)
          .with("/opt/conda/bin/python -m pip install -r requirements.txt")

        opener = LearnOpen::Opener.new("jupyter_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: spy)
        opener.run
      end

      it "opens browser in IDE"  do
        environment = {"CREATED_USER" => "bobby", "IDE_CONTAINER" => "true", "LAB_NAME" => "jupyter_lab"}
        io = StringIO.new
        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new("jupyter_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: io)
        opener.run
        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening Jupyter Lesson...
EOF

        custom_commands_log = File.read("#{home_dir}/.custom_commands.log")
        expect(custom_commands_log).to eq("{\"command\":\"browser_open\",\"url\":\"https://learn.co/lessons/31322\"}\n")
      end
      it "opens the lab in the safari on mac"  do
        expect(system_adapter)
          .to receive(:run_command)
          .with("open -a Safari https://learn.co/lessons/31322")
        io = StringIO.new
        opener = LearnOpen::Opener.new("jupyter_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       system_adapter: system_adapter,
                                       io: io,
                                       git_ssh_connector: git_ssh_connector,
                                       platform: "darwin")
        opener.run
        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening Jupyter Lesson...
EOF
      end
      it "opens the lab in the chrome on mac if present" do
        FileUtils.mkdir_p("/Applications")
        FileUtils.touch('/Applications/Google Chrome.app')
        expect(system_adapter)
          .to receive(:run_command)
          .with("open -a 'Google Chrome' https://learn.co/lessons/31322")

        io = StringIO.new
        opener = LearnOpen::Opener.new("jupyter_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       system_adapter: system_adapter,
                                       io: io,
                                       git_ssh_connector: git_ssh_connector,
                                       platform: "darwin")
        opener.run
        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening Jupyter Lesson...
EOF
      end

      it "opens the lab in the browser on linux" do
        expect(system_adapter)
          .to receive(:run_command)
          .with("xdg-open https://learn.co/lessons/31322")
        io = StringIO.new
        opener = LearnOpen::Opener.new("jupyter_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       system_adapter: system_adapter,
                                       io: io,
                                       git_ssh_connector: git_ssh_connector,
                                       platform: "linux")
        opener.run
        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening Jupyter Lesson...
EOF
      end
    end
    context "Readme" do
      it "does not open readme if on unsupported environment" do
        io = StringIO.new
        opener = LearnOpen::Opener.new("readme", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: {},
                                       system_adapter: system_adapter,
                                       io: io,
                                       platform: "chromeos")
        opener.run

        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
It looks like this lesson is a Readme. Please open it in your browser.
EOF
      end

      it "writes to custom_commands_log on IDE" do
        environment = {"CREATED_USER" => "bobby", "IDE_CONTAINER" => "true", "LAB_NAME" => "readme"}
        io = StringIO.new
        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new("readme", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: io)
        opener.run

        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening readme...
EOF
        custom_commands_log = File.read("#{home_dir}/.custom_commands.log")
        expect(custom_commands_log).to eq("{\"command\":\"browser_open\",\"url\":\"https://learn.co/lessons/31322\"}\n")
      end
      context "on a mac" do
        it "opens safari by default" do
          io = StringIO.new
          expect(system_adapter)
            .to receive(:run_command)
            .with("open -a Safari https://learn.co/lessons/31322")

          opener = LearnOpen::Opener.new("readme", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {},
                                         system_adapter: system_adapter,
                                         io: io,
                                         git_ssh_connector: git_ssh_connector,
                                         platform: "darwin")
          opener.run

          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening readme...
EOF
        end

        it "opens chrome if it exists" do
          FileUtils.mkdir_p("/Applications")
          FileUtils.touch('/Applications/Google Chrome.app')
          io = StringIO.new
          expect(system_adapter)
            .to receive(:run_command)
            .with("open -a 'Google Chrome' https://learn.co/lessons/31322")


          opener = LearnOpen::Opener.new("readme", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {},
                                         system_adapter: system_adapter,
                                         io: io,
                                         git_ssh_connector: git_ssh_connector,
                                         platform: "darwin")
          opener.run

          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening readme...
EOF
        end
      end

      context "on linux" do
        it "opens in default brower" do
          io = StringIO.new
          expect(system_adapter)
            .to receive(:run_command)
            .with("xdg-open https://learn.co/lessons/31322")


          opener = LearnOpen::Opener.new("readme", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {},
                                         system_adapter: system_adapter,
                                         git_ssh_connector: git_ssh_connector,
                                         io: io,
                                         platform: "linux")
          opener.run

          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening readme...
EOF
        end
      end
    end
    context "iOS labs" do
      it "fails to open on Linux" do
        io = StringIO.new

        opener = LearnOpen::Opener.new("ios_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: io,
                                       platform: "linux")
        opener.run

        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
You need to be on a Mac to work on iOS lessons.
EOF
      end

      it "fails to open on the IDE" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "ios_lab",
          "CREATED_USER" => "bobby",
          "IDE_CONTAINER" => "true",
          "IDE_VERSION" => "3"
        }
        create_linux_home_dir("bobby")
        io = StringIO.new

        opener = LearnOpen::Opener.new("ios_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       git_ssh_connector: git_ssh_connector,
                                       io: io,
                                       platform: "linux")
        opener.run

        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
You need to be on a Mac to work on iOS lessons.
EOF
      end

      it "opens xcodeproj if on a mac and it exists" do
        io = StringIO.new
        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/ios_lab")
        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")
        expect(system_adapter)
          .to receive(:run_command)
          .with("cd /home/bobby/Development/code/ios_lab && open *.xcodeproj")


        opener = LearnOpen::Opener.new("ios_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                       system_adapter: system_adapter,
                                       io: io,
                                       git_ssh_connector: git_ssh_connector,
                                       platform: "darwin")
        opener.run

      end
      it "opens xcworkspace if on a mac and it exists" do
        io = StringIO.new
        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/ios_with_workspace_lab")
        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")
        expect(system_adapter)
          .to receive(:run_command)
          .with("cd /home/bobby/Development/code/ios_with_workspace_lab && open *.xcworkspace")


        opener = LearnOpen::Opener.new("ios_with_workspace_lab", "atom", false, false,
                                       learn_web_client: learn_web_client,
                                       git_adapter: git_adapter,
                                       environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                       system_adapter: system_adapter,
                                       io: io,
                                       git_ssh_connector: git_ssh_connector,
                                       platform: "darwin")
        opener.run

      end
    end
    context "Lab" do
      context "installing dependencies" do
        it "runs bundle install if lab is a ruby lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: ["atom", path: "."],
              open_login_shell: ["/usr/local/bin/fish"],
              change_context_directory: ["/home/bobby/Development/code/rails-dynamic-request-lab-cb-000"],
            )

          expect(system_adapter)
            .to receive(:run_command)
            .with("bundle install")
          opener = LearnOpen::Opener.new("ruby_lab", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         git_ssh_connector: git_ssh_connector,
                                         io: spy)
          opener.run
        end

        it "outputs correctly for ruby lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: :noop,
              open_login_shell: :noop,
              change_context_directory: :noop,
              run_command: :noop,
            )

          io = StringIO.new
          opener = LearnOpen::Opener.new("ruby_lab", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         git_ssh_connector: git_ssh_connector,
                                         io: io)
          opener.run
          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Opening lesson...
Bundling...
Done.
EOF
        end

        it "runs pip install if lab is a python lab" do
          expect(system_adapter)
            .to receive(:open_editor)
            .with("atom", path: ".")

          expect(system_adapter)
            .to receive(:open_login_shell)
            .with("/usr/local/bin/fish")

          expect(system_adapter)
            .to receive(:change_context_directory)
            .with("/home/bobby/Development/code/python_lab")

          expect(system_adapter)
            .to receive(:run_command)
            .with("python -m pip install -r requirements.txt")
          opener = LearnOpen::Opener.new("python_lab", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         git_ssh_connector: git_ssh_connector,
                                         io: spy)
          opener.run
        end
        it "outputs correctly for python lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: :noop,
              open_login_shell: :noop,
              change_context_directory: :noop,
              run_command: :noop,
            )

          io = StringIO.new
          opener = LearnOpen::Opener.new("python_lab", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         git_ssh_connector: git_ssh_connector,
                                         io: io)
          opener.run
          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Opening lesson...
Installing pip dependencies...
Done.
EOF
        end

        it "runs npm install if lab is a node lab" do
          expect(system_adapter)
            .to receive(:open_editor)
            .with("atom", path: ".")

          expect(system_adapter)
            .to receive(:open_login_shell)
            .with("/usr/local/bin/fish")

          expect(system_adapter)
            .to receive(:change_context_directory)
            .with("/home/bobby/Development/code/node_lab")

          expect(system_adapter)
            .to receive(:run_command)
            .with("npm install")
          opener = LearnOpen::Opener.new("node_lab", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         git_ssh_connector: git_ssh_connector,
                                         io: spy)
          opener.run
        end
        it "outputs correctly for node lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: :noop,
              open_login_shell: :noop,
              change_context_directory: :noop,
              run_command: :noop,
            )

          io = StringIO.new
          opener = LearnOpen::Opener.new("node_lab", "atom", false, false,
                                         learn_web_client: learn_web_client,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         git_ssh_connector: git_ssh_connector,
                                         io: io)
          opener.run
          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Opening lesson...
Installing npm dependencies...
Done.
EOF
        end
      end
      end
    end
  end
