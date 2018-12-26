$VERBOSE = nil # for hide ruby warnings

require 'vcr'

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda'
require 'rails-controller-testing' if Rails.version < '5.0'
require 'timecop'

Rails::Controller::Testing.install unless Rails.version < '5.0'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', [:auth_sources])

VCR.configure do |config|
  config.cassette_library_dir = File.join(Rails.root, 'plugins/redmine_2fa/test/fixtures/vcr_cassettes')
  config.hook_into :webmock
end

