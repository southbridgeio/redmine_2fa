require File.expand_path('../../../test_helper', __FILE__)
class SecondAuthenticationsTest < Redmine::RoutingTest
  def test_second_authentications
    assert_routing({ method: 'delete', path: '/redmine_2fa/users/id/reset' },
                   controller: 'second_authentications', action: 'destroy', id: 'id')
  end
end
