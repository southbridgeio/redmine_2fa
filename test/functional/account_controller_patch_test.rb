require File.expand_path('../../test_helper', __FILE__)

class AccountControllerPatchTest < ActionController::TestCase
  fixtures :users, :roles

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Redmine2FA::OtpAuth.any_instance.stubs(:send_otp_code).returns('123456')

    User.current = nil
    @user = User.find(2) # jsmith
    @user.otp_regenerate_secret
  end

  def test_login_with_wrong_password
    post :login, username: 'jsmith', password: 'bad'
    assert_response :success
    assert_template 'login'

    assert_select 'div.flash.error', text: /Invalid user or password/
    assert_select 'input[name=username][value=jsmith]'
    assert_select 'input[name=password]'
    assert_select 'input[name=password][value]', 0
  end

  def test_login_without_2fa
    post :login, username: 'jsmith', password: 'jsmith'
    assert_redirected_to '/my/page'
  end

  def test_login_with_2fa
    User.any_instance.expects(:has_otp_auth?).returns(true)

    post :login, username: 'jsmith', password: 'jsmith'

    assert_template 'redmine_2fa'
    assert @request.session[:otp_user_id] == 2
    assert @request.session[:otp_failed_attempts].zero?
  end

  def test_login_with_back_url
    User.any_instance.expects(:has_otp_auth?).returns(true)

    post :login, username: 'jsmith', password: 'jsmith', back_url: 'http://localhost/somewhere'
    assert @request.session[:otp_back_url] == 'http://localhost/somewhere'
  end

  #
  # def test_otp_code_confirm_with_wrong_otp_code
  #   @request.session[:otp_user_id]       = 2
  #   @request.session[:otp_code] = '1234'
  #   post :otp_code_confirm, otp_code: '12345'
  #
  #   assert_template 'redmine_2fa'
  #   assert_select 'div.flash.error', text: /Wrong SMS confirmation password/
  # end
  #
  # def test_otp_code_confirm_with_wrong_otp_code_limit_of_failed_attempts_exceeded
  #   User.find(2).update_attribute :mobile_phone, '79999999999'
  #   #
  #   # Redmine2FA::OtpAuth.expects(:generate_otp_code).returns('7890')
  #   # Redmine2FA::OtpAuth.expects(:send_otp_code).with('79999999999', '7890')
  #
  #   @request.session[:otp_user_id]              = 2
  #   @request.session[:otp_code]        = '1234'
  #   @request.session[:telegram_failed_attempts] = 2
  #
  #   post :otp_code_confirm, otp_code: '12345'
  #   assert_select 'div.flash.error', text: /New password sent/
  #   assert @request.session[:otp_user_id] == 2
  #   assert @request.session[:otp_code] == '7890'
  #   assert @request.session[:telegram_failed_attempts].zero?
  # end
  #
  # def test_otp_code_confirm_with_correct_otp_code
  #   @request.session[:otp_user_id]       = 2
  #   @request.session[:otp_code] = '1234'
  #   @request.session[:otp_back_url] = 'http://localhost/somewhere'
  #   post :otp_code_confirm, otp_code: '1234'
  #
  #   assert_redirected_to '/my/page'
  #   assert User.current == User.find(2)
  #   assert @request.session[:otp_user_id].nil?
  #   assert @request.session[:otp_code].nil?
  #   assert @request.session[:telegram_failed_attempts].nil?
  #   assert @request.session[:otp_back_url].nil?
  #   assert @request.params[:back_url] == 'http://localhost/somewhere'
  # end
  #
  # def test_otp_code_resend_without_telegram_user_id_in_session
  #   @request.session[:otp_user_id]       = nil
  #   @request.session[:otp_code] = '1234'
  #   get :otp_code_resend
  #   assert_redirected_to '/'
  # end
  #
  # def test_otp_code_resend_without_otp_code_in_session
  #   @request.session[:otp_user_id]       = 2
  #   @request.session[:otp_code] = nil
  #   get :otp_code_resend
  #   assert_redirected_to '/'
  # end
  #
  # def test_otp_code_resend
  #   User.find(2).update_attribute :mobile_phone, '79999999999'
  #   @request.session[:otp_user_id]       = 2
  #   @request.session[:otp_code] = '1234'
  #
  #   # Redmine2FA::OtpAuth.expects(:send_otp_code).with('79999999999', '5678')
  #
  #   get :otp_code_resend
  #
  #   assert_template 'redmine_2fa'
  #   assert_select 'div.flash.notice', text: /SMS confirmation password sent again/
  #   assert @request.session[:otp_user_id] == 2
  #   assert @request.session[:telegram_failed_attempts].zero?
  # end
end
