require File.expand_path('../../../test_helper', __FILE__)
class UserMobilePhoneTest < Redmine::RoutingTest
  def test_user_mobile_phone
    should_route 'PUT /redmine_2fa/mobile_phone/update' => 'user_mobile_phone#update'
    should_route 'POST /redmine_2fa/mobile_phone/confirm' => 'user_mobile_phone#confirm'
  end
end
