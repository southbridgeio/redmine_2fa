require File.expand_path('../../../test_helper', __FILE__)
class SecondAuthenticationsTest < Redmine::RoutingTest
  def test_second_authentications
    should_route 'PUT redmine_2fa/confirm' => 'second_authentications#update'
    should_route 'DELETE redmine_2fa/reset' => 'second_authentications#destroy'
  end
end
