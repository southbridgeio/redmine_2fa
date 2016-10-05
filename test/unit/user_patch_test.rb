require File.expand_path('../../test_helper', __FILE__)

class UserPatchTest < ActiveSupport::TestCase
  def setup
    @user           = User.new
    @user.login     = 'test'
    @user.password  = 'testtest'
    @user.firstname = 'Test'
    @user.lastname  = 'Test'
    @user.mail      = 'mail@test.org'
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

  context 'mobile phone' do
    context 'validation' do
      should 'contain only numbers' do
        user = User.new mobile_phone: '7894561230'
        user.valid?
        assert user.errors[:mobile_phone].empty?
      end

      should 'can be empty' do
        user = User.new mobile_phone: ''
        user.valid?
        assert user.errors[:mobile_phone].empty?
      end

      should 'can be nil' do
        user = User.new mobile_phone: nil
        user.valid?
        assert user.errors[:mobile_phone].empty?
      end

      should 'not contain + symbol' do
        user = User.new mobile_phone: '+7894561230'
        user.valid?
        assert user.errors[:mobile_phone].present?
      end

      should 'not contain - symbol' do
        user = User.new mobile_phone: '7894-561-230'
        user.valid?
        assert user.errors[:mobile_phone].present?
      end
    end

    context 'confirmation' do
      setup do
        User.any_instance.stubs(:mobile_phone).returns('79243216547')
      end

      should 'confirm mobile phone with valid code' do
        User.any_instance.expects(:authenticate_otp).returns(true)

        @user.confirm_mobile_phone('valid')
        @user.reload
        assert @user.mobile_phone_confirmed?
      end

      should 'return errors with invalid code' do
        User.any_instance.expects(:authenticate_otp).returns(false)
        @user.confirm_mobile_phone('invalid')
        @user.reload
        assert !@user.mobile_phone_confirmed?
        assert @user.errors.present?
      end
    end
  end
end
