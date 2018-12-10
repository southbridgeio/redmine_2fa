$VERBOSE = nil # for hide ruby warnings

require 'vcr'

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

require 'minitest/autorun'
require 'minitest/reporters'

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', [:auth_sources])

VCR.configure do |config|
  config.cassette_library_dir = File.join(Rails.root, 'plugins/redmine_2fa/test/fixtures/vcr_cassettes')
  config.hook_into :webmock
end

class ActiveSupport::TestCase
  extend Minitest::Spec::DSL
end
