require File.expand_path('../../../test_helper', __FILE__)

class OtpBotWebhookTest < Redmine::RoutingTest
  def test_otp_bot_webhook
    assert_routing({ method: 'post', path: '/redmine_2fa/bot/adafsgsgdsgsd:token/update' },
                   controller: 'otp_bot_webhook', action: 'update', token: 'adafsgsgdsgsd:token')
  end
end
