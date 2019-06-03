require 'diff/lcs'
require_relative '../lib/learn_open'
require_relative 'fakes/fake_git.rb'
require_relative 'fakes/fake_learn_client.rb'

ENV["GEM_ENV"] = "test"

def home_dir
  Dir.home
end

def create_home_dir
  FileUtils.mkdir_p home_dir
end

def create_linux_home_dir(username)
  home_dir = "/home/#{username}"
  FileUtils.mkdir_p home_dir
  home_dir
end

def create_netrc_file
  File.open("#{home_dir}/.netrc", "w+") do |f|
    f.write(<<-EOF)
machine learn-config
login learn
password some-amazing-password
    EOF
  end
  File.chmod(0600, "#{home_dir}/.netrc")
end

def create_learn_config_file
  File.open("#{home_dir}/.learn-config", "w+") do |f|
    f.write(<<-EOF)
---
:learn_directory: "/home/bobby/Development/code"
:editor: atom
    EOF
  end
end

