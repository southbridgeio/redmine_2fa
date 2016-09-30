require File.expand_path('../../test_helper', __FILE__)

class SecondAuthenticationsControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :roles

  def setup
    @user = User.find(2)

    @auth_source = Redmine2FA::AuthSource::GoogleAuth.create name: 'Google Auth', onthefly_register: false, tls: false
  end

  def test_confirm_auth_source
    @request.session[:otp_user_id] = @user.id

    Redmine2FA::OtpAuth.any_instance.expects(:send_otp_code)

    put :update, auth_source_id: @auth_source.id

    assert_template 'account/redmine_2fa'

    @user.reload

    assert_equal @auth_source.id, @user.auth_source_id
  end

  def test_confirm_auth_source_not_update_user_without_session
    @request.session[:otp_user_id] = nil

    put :update, auth_source_id: @auth_source.id

    @user.reload

    assert_not_equal @auth_source.id, @user.auth_source_id
  end

end
