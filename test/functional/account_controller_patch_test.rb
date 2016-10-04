require File.expand_path('../../test_helper', __FILE__)

class AccountControllerPatchTest < ActionController::TestCase
  fixtures :users, :roles

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Redmine2FA::OtpAuth.any_instance.stubs(:send_code).returns('123456')

    User.current = nil
    @user = User.find(2) # jsmith
    @user.otp_regenerate_secret
  end

  context 'prepare' do
    should 'set otp session'
  end
end
