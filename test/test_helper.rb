$VERBOSE = nil # for hide ruby warnings

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda'
require 'rails-controller-testing'
require 'timecop'

Rails::Controller::Testing.install unless Rails.version < '5.0'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
