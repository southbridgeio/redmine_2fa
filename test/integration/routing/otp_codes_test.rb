require File.expand_path('../../../test_helper', __FILE__)
class OtpCodesTest < Redmine::RoutingTest
  def test_otp_codes
    should_route 'POST /redmine_2fa/otp_code/resend' => 'otp_codes#create'
  end
end
