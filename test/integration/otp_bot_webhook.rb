require File.expand_path('../../test_helper', __FILE__)

class OtpBotWebhook < Redmine::IntegrationTest

  setup do
    Setting.create name: 'plugin_redmine_2fa', value: { 'bot_token' => '12345678:botSecretToken' }
  end

  #
  # {"update_id"=>959061985, "message"=>{"message_id"=>509, "from"=>{"id"=>1072324, "first_name"=>"Artur", "last_name"=>"Trofimov", "username"=>"artur_trofimov"}, "chat"=>{"id"=>1072324, "first_name"=>"Artur", "last_name"=>"Trofimov", "username"=>"artur_trofimov", "type"=>"private"}, "date"=>1474591891, "text"=>"/start", "entities"=>[{"type"=>"bot_command", "offset"=>0, "length"=>6}]}, "controller"=>"otp_bot", "action"=>"update"}

  def test_authourized_update
    bot_token = Setting.plugin_redmine_2fa['bot_token']
    post "redmine_2fa/bot/#{bot_token}/update", message: { text: '/start', from: { id: 123 } }

  end

  def test_unauthorized_update

  end

  def test_user_add_bot

  end

  def test_user_remove_bot

  end
end
