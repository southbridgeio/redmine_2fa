require File.expand_path('../../test_helper', __FILE__)

class UserMobilePhoneControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :user_preferences, :roles, :projects, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :enumerations, :custom_fields, :auth_sources

  def setup
    @request.session[:user_id] = 2
    @user                      = User.find(2)
    @user.otp_regenerate_secret
    @user.save
  end

  def test_user_phone_update
    post :update, user: { mobile_phone: '79241234567' }

    assert_equal @user, assigns(:user)

    @user.reload

    assert_equal '79241234567', @user.mobile_phone
  end

  def test_user_phone_validation
    skip
  end

  def test_user_phone_confirmation
    @user.update mobile_phone: '79243216547'

    post :confirm, code: @user.otp_code

    @user.reload

    assert @user.mobile_phone_confirmed?
  end

  def test_user_phone_confirmation_with_wrong_code
    @user.update mobile_phone: '79243216547'

    post :confirm, code: '12345'

    @user.reload

    assert !@user.mobile_phone_confirmed?
  end
end
