$VERBOSE = nil # for hide ruby warnings

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

VCR.configure do |config|
  config.cassette_library_dir = File.join(Rails.root, 'plugins/redmine_2fa/test/fixtures/vcr_cassettes')
  config.hook_into :webmock
end

