require File.expand_path('../../test_helper', __FILE__)

class OtpBotWebhookControllerTest < ActionController::TestCase
  setup do
    @valid_token = 'valid:token'
    Redmine2FA.expects(:bot_token).at_least_once.returns(@valid_token)
    Telegrammer::Bot.any_instance.stubs(:get_me)
  end

  def test_unauthorized_access
    post :update, message: message_hash, token: 'invalid'
    assert_response 403
  end

  def test_user_add_bot
    TelegramCommon::Bot.any_instance.expects(:start)

    post :update, message: message_hash, token: @valid_token

    assert_response :ok
  end

  def test_connect_command
    TelegramCommon::Bot.any_instance.expects(:connect)

    message        = message_hash
    message[:text] = '/connect user@email.com'

    post :update, message: message, token: @valid_token

    assert_response :ok
  end

  private

  def message_hash
    { text: '/start', from: { id: 123, first_name: 'John', last_name: 'Smith' } }
  end
end
