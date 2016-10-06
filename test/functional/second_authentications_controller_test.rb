require File.expand_path('../../test_helper', __FILE__)

class SecondAuthenticationsControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user = User.find(2)

    User.any_instance.stubs(:otp_code)

    @auth_source = auth_sources(:google_auth)
  end



  context 'reset' do

  end

end
