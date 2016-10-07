require File.expand_path('../../test_helper', __FILE__)

class UserMobilePhoneControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :roles

  def setup
    @user = User.find(2)
  end

  def test_user_phone_update
    @request.session[:otp_user_id] = @user.id
    User.any_instance.expects(:otp_code).returns('123456')
    post :update, user: { mobile_phone: '79241234567' }

    assert_equal @user, assigns(:user)

    @user.reload

    assert_equal '79241234567', @user.mobile_phone
  end

  def test_user_phone_update_unauthorized
    post :update, user: { mobile_phone: '5555555' }

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

    post :confirm, code: '12345'

    @user.reload

    assert @user.mobile_phone_confirmed?
  end

  def test_user_phone_confirmation_with_wrong_code
    @request.session[:otp_user_id] = @user.id
    User.any_instance.expects(:mobile_phone).returns('7894561230')
    User.any_instance.expects(:authenticate_otp).returns(false)

    post :confirm, code: '12345'

    @user.reload

    assert !@user.mobile_phone_confirmed?
  end
end
