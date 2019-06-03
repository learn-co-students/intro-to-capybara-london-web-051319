require 'spec_helper'
require 'fakefs/spec_helpers'

describe LearnOpen::ArgumentParser do
  include FakeFS::SpecHelpers
  let(:home_dir) { File.expand_path('~') }

  before do
    FileUtils.mkdir_p home_dir
  end

  context "" do
  it 'reads the .learn-config for the editor' do
    File.open("#{home_dir}/.learn-config", "w+") do |f|
      f.puts <<-EOF
---
:learn_directory: "#{home_dir}/Development/code"
:editor: vim
EOF
    end
    args = ['--editor=']
    _lesson, editor, _load_next = LearnOpen::ArgumentParser.new(args).execute
    expect(editor).to eq('vim')
  end

  it 'ignores switches in the editor field' do
    File.open("#{home_dir}/.learn-config", "w+") do |f|
      f.puts <<-EOF
---
:learn_directory: "#{home_dir}/Development/code"
:editor: vim -m
EOF
    end
    args = ['--editor=']
    _lesson, editor, _load_next = LearnOpen::ArgumentParser.new(args).execute
    expect(editor).to eq('vim')
  end

  it 'overrides editor is passed in as argument' do
    File.open("#{home_dir}/.learn-config", "w+") do |f|
      f.puts <<-EOF
---
:learn_directory: "#{home_dir}/Development/code"
:editor: vim -m
EOF
    end
    args = ['--editor=atom']
    _lesson, editor, _load_next = LearnOpen::ArgumentParser.new(args).execute
    expect(editor).to eq('atom')
  end

  it 'parses next lab if --next spedified' do
    File.open("#{home_dir}/.learn-config", "w+") do |f|
      f.puts <<-EOF
---
:learn_directory: "#{home_dir}/Development/code"
:editor: atom
EOF
    end
    args = ['--next', '--editor=vim']
    _lesson, editor, load_next = LearnOpen::ArgumentParser.new(args).execute
    expect(load_next).to eq(true)
    expect(editor).to eq('vim')
  end

  it 'parses lab name if provided' do
    File.open("#{home_dir}/.learn-config", "w+") do |f|
      f.puts <<-EOF
---
:learn_directory: "#{home_dir}/Development/code"
:editor: emacs
EOF
    end
    args = ['hashketball', '--editor=vim']
    lesson, editor, _load_next = LearnOpen::ArgumentParser.new(args).execute
    expect(lesson).to eq('hashketball')
    expect(editor).to eq('vim')
  end

  it 'accepts a --clone-only argument' do
    File.open("#{home_dir}/.learn-config", "w+") do |f|
      f.puts <<-EOF
---
:learn_directory: "#{home_dir}/Development/code"
:editor: emacs
EOF
    end
    args = ['hashketball', '--editor=vim', '--clone-only']
    _lesson, _editor, _load_next, clone_only = LearnOpen::ArgumentParser.new(args).execute
    expect(clone_only).to eq(true)
  end
  end
end
