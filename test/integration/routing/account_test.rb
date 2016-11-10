require File.expand_path('../../../test_helper', __FILE__)
class AccountTest < Redmine::RoutingTest
  def test_account_routes
    should_route 'POST /redmine_2fa/confirm' => 'account#confirm_2fa'
    should_route 'POST /redmine_2fa/otp_code/confirm' => 'account#confirm_otp'
  end
end
