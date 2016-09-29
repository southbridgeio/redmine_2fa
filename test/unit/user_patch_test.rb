require File.expand_path('../../test_helper', __FILE__)

class UserPatchTest < ActiveSupport::TestCase
  def setup
    @user = User.new
    @user.login = 'test'
    @user.password = 'testtest'
    @user.firstname = 'Test'
    @user.lastname = 'Test'
    @user.mail = 'mail@test.org'
    @user.save
  end

  def test_otp_secret_key
    assert_not_nil @user.otp_secret_key
  end

  def test_otp_expiration_time
    time = Time.now.beginning_of_minute

    otp_code = @user.otp_code(time: time)

    Timecop.freeze(time) do
      assert @user.authenticate_otp(otp_code, drift: 120)
    end

    Timecop.freeze(time + 2.minutes) do
      assert @user.authenticate_otp(otp_code, drift: 120)
    end

    Timecop.freeze(time + 3.minutes) do
      assert !@user.authenticate_otp(otp_code, drift: 120)
    end
  end

  def test_mobile_phone_blank_by_default
    assert @user.mobile_phone.blank?
  end

  def test_mobile_phone_not_confirmed_by_default
    assert !@user.mobile_phone_confirmed?
  end

  def test_mobile_phone_will_not_confirm_without_mobile_phone
    code = @user.otp_code
    @user.confirm_mobile_phone(code)
    @user.reload
    assert !@user.mobile_phone_confirmed?
  end

  def test_mobile_phone_confirm
    @user.mobile_phone = '79243216547'
    code = @user.otp_code
    @user.confirm_mobile_phone(code)
    @user.reload
    assert @user.mobile_phone_confirmed?
  end
end
