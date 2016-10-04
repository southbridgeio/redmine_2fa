require File.expand_path('../../../test_helper', __FILE__)
class OtpBotTest < Redmine::RoutingTest
  def test_otp_bot
    should_route 'POST /redmine_2fa/bot/init' => 'otp_bot#create'
    should_route 'DELETE /redmine_2fa/bot/reset' => 'otp_bot#destroy'
  end
end
