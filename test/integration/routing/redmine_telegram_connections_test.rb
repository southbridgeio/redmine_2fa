require File.expand_path('../../../test_helper', __FILE__)
class RedmineTelegramConnectionsTest < Redmine::RoutingTest
  def test_redmine_telegram_connections
    should_route 'GET /telegram/connect' => 'redmine_telegram_connections#create'
  end
end
