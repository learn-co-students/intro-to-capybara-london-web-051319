require 'fileutils'
require 'oj'
require 'colorize'

require_relative 'learn_test/version'
require_relative 'learn_test/netrc_interactor'
require_relative 'learn_test/github_interactor'
require_relative 'learn_test/user_id_parser'
require_relative 'learn_test/username_parser'
require_relative 'learn_test/learn_oauth_token_parser'
require_relative 'learn_test/repo_parser'
require_relative 'learn_test/file_finder'
require_relative 'learn_test/runner'

require_relative 'learn_test/dependency'

require_relative 'learn_test/strategy'
require_relative 'learn_test/js_strategy'
require_relative 'learn_test/strategies/jasmine'
require_relative 'learn_test/strategies/rspec'
require_relative 'learn_test/strategies/karma'
require_relative 'learn_test/strategies/protractor'
require_relative 'learn_test/strategies/java_junit'
require_relative 'learn_test/strategies/csharp_nunit'
require_relative 'learn_test/strategies/mocha'
require_relative 'learn_test/strategies/green_onion'
require_relative 'learn_test/strategies/pytest'

module LearnTest
  module Dependencies
    autoload :NodeJS,         'learn_test/dependencies/nodejs'
    autoload :PhantomJS,      'learn_test/dependencies/phantomjs'
    autoload :Karma,          'learn_test/dependencies/karma'
    autoload :Protractor,     'learn_test/dependencies/protractor'
    autoload :Java,           'learn_test/dependencies/java'
    autoload :CSharp,         'learn_test/dependencies/csharp'
    autoload :Ant,            'learn_test/dependencies/ant'
    autoload :Imagemagick,    'learn_test/dependencies/imagemagick'
    autoload :SeleniumServer, 'learn_test/dependencies/selenium_server'
    autoload :Firefox,        'learn_test/dependencies/firefox'
    autoload :GreenOnion,     'learn_test/dependencies/green_onion'
    autoload :Pytest,         'learn_test/dependencies/pytest'
  end
end
