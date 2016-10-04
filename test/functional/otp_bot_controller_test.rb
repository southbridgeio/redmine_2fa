require File.expand_path('../../test_helper', __FILE__)

class OtpBotControllerTest < ActionController::TestCase
  fixtures :users, :roles

  setup do
    Setting.create name: 'plugin_redmine_2fa', value: { 'bot_token' => '12345678:botSecretToken' }
    Setting['host_name'] = 'redmine.test'
    @request             = ActionController::TestRequest.new
    @response            = ActionController::TestResponse.new
  end

  def test_init
    @request.session[:user_id] = 1

    plugin_settings      = Setting.find_by(name: 'plugin_redmine_2fa')
    plugin_settings_hash = plugin_settings.value

    assert plugin_settings_hash['bot_name'].nil?
    assert plugin_settings_hash['bot_id'].nil?

    VCR.use_cassette('init') { post :create }

    plugin_settings      = Setting.find_by(name: 'plugin_redmine_2fa')
    plugin_settings_hash = plugin_settings.value

    assert_not plugin_settings_hash['bot_name'].nil?
    assert_not plugin_settings_hash['bot_id'].nil?
  end

  def test_reset

  end
end
