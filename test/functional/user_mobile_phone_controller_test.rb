require File.expand_path('../../test_helper', __FILE__)

class UserMobilePhoneControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :roles

  def setup
    @user = User.find(2)
    RedmineTwoFa::Protocols::Sms.any_instance.expects(:send_code)
  end

  def test_user_phone_update
    @request.session[:otp_user_id] = @user.id
    User.any_instance.expects(:otp_code).returns('123456')
    if Rails.version < '5.0'
      post :update, user: { mobile_phone: '79241234567' }, format: 'js'
    else
      post :update, params: { user: { mobile_phone: '79241234567' } }, format: 'js'
    end

    assert_equal @user, assigns(:user)

    @user.reload

    assert_equal '79241234567', @user.mobile_phone
  end

  def test_user_phone_update_unauthorized
    if Rails.version < '5.0'
      post :update, user: { mobile_phone: '5555555' }
    else
      post :update, params: { user: { mobile_phone: '5555555' } }
    end

    @user.reload

    assert_not_equal '5555555', @user.mobile_phone
  end

  def test_user_phone_validation
    skip 'TODO: write validation logic and test for it'
  end

  def test_user_phone_confirmation
    @request.session[:otp_user_id] = @user.id
    User.any_instance.stubs(:mobile_phone).returns('7894561230')
    User.any_instance.expects(:authenticate_otp).returns(true)

    if Rails.version < '5.0'
      post :confirm, code: '12345', format: 'js'
    else
      post :confirm,  params: { code: '12345' }, format: 'js'
    end

    @user.reload

    assert @user.mobile_phone_confirmed?
  end

  def test_user_phone_confirmation_with_wrong_code
    @request.session[:otp_user_id] = @user.id
    User.any_instance.expects(:mobile_phone).returns('7894561230')
    User.any_instance.expects(:authenticate_otp).returns(false)

    if Rails.version < '5.0'
      post :confirm, code: '12345', format: 'js'
    else
      post :confirm, params: { code: '12345' }, format: 'js'
    end

    @user.reload

    assert !@user.mobile_phone_confirmed?
  end
end
