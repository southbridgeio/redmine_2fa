require File.expand_path('../../test_helper', __FILE__)

class AccountControllerPatchTest < ActionController::TestCase
  fixtures :users, :roles

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    auth_source = Redmine2FA::AuthSourceTelegram.create name: 'Telegram', onthefly_register: false, tls: false
    User.current = nil
    user = User.find(2) # jsmith
    user.update_attribute :auth_source_id, auth_source.id
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

  def test_login_without_otp_code
    post :login, username: 'dlopper', password: 'foo'
    assert_redirected_to '/my/page'
  end

  def test_login_without_mobile_phone
    post :login, username: 'jsmith', password: 'jsmith'
    assert_redirected_to '/my/page'
  end

  def test_login_with_mobile_phone
    User.find(2).update_attribute :mobile_phone, '79999999999'

    Redmine2FA::OtpAuth.expects(:generate_telegram_password).returns('1234')
    Redmine2FA::OtpAuth.expects(:send_telegram_password).with('79999999999', '1234')

    post :login, username: 'jsmith', password: 'jsmith'

    assert_template 'telegram'
    assert @request.session[:otp_user_id] == 2
    assert @request.session[:telegram_password] == '1234'
    assert @request.session[:telegram_failed_attempts].zero?
  end

  def test_login_with_back_url
    User.find(2).update_attribute :mobile_phone, '79999999999'
    post :login, username: 'jsmith', password: 'jsmith', back_url: 'http://localhost/somewhere'
    assert @request.session[:telegram_back_url] == 'http://localhost/somewhere'
  end

  def test_telegram_confirm_without_telegram_user_id_in_session
    @request.session[:otp_user_id]       = nil
    @request.session[:telegram_password] = '1234'
    post :telegram_confirm, telegram_password: '1234'
    assert_redirected_to '/'
  end

  def test_telegram_confirm_without_telegram_password_in_session
    @request.session[:otp_user_id]       = 2
    @request.session[:telegram_password] = nil
    post :telegram_confirm, telegram_password: '1234'
    assert_redirected_to '/'
  end

  def test_telegram_confirm_with_wrong_telegram_password
    @request.session[:otp_user_id]       = 2
    @request.session[:telegram_password] = '1234'
    post :telegram_confirm, telegram_password: '12345'

    assert_template 'telegram'
    assert_select 'div.flash.error', text: /Wrong SMS confirmation password/
  end

  def test_telegram_confirm_with_wrong_telegram_password_limit_of_failed_attempts_exceeded
    User.find(2).update_attribute :mobile_phone, '79999999999'

    Redmine2FA::OtpAuth.expects(:generate_telegram_password).returns('7890')
    Redmine2FA::OtpAuth.expects(:send_telegram_password).with('79999999999', '7890')

    @request.session[:otp_user_id]              = 2
    @request.session[:telegram_password]        = '1234'
    @request.session[:telegram_failed_attempts] = 2

    post :telegram_confirm, telegram_password: '12345'
    assert_select 'div.flash.error', text: /New password sent/
    assert @request.session[:otp_user_id] == 2
    assert @request.session[:telegram_password] == '7890'
    assert @request.session[:telegram_failed_attempts].zero?
  end

  def test_telegram_confirm_with_correct_telegram_password
    @request.session[:otp_user_id]       = 2
    @request.session[:telegram_password] = '1234'
    @request.session[:telegram_back_url] = 'http://localhost/somewhere'
    post :telegram_confirm, telegram_password: '1234'

    assert_redirected_to '/my/page'
    assert User.current == User.find(2)
    assert @request.session[:otp_user_id].nil?
    assert @request.session[:telegram_password].nil?
    assert @request.session[:telegram_failed_attempts].nil?
    assert @request.session[:telegram_back_url].nil?
    assert @request.params[:back_url] == 'http://localhost/somewhere'
  end

  def test_telegram_resend_without_telegram_user_id_in_session
    @request.session[:otp_user_id]       = nil
    @request.session[:telegram_password] = '1234'
    get :telegram_resend
    assert_redirected_to '/'
  end

  def test_telegram_resend_without_telegram_password_in_session
    @request.session[:otp_user_id]       = 2
    @request.session[:telegram_password] = nil
    get :telegram_resend
    assert_redirected_to '/'
  end

  def test_telegram_resend
    User.find(2).update_attribute :mobile_phone, '79999999999'
    @request.session[:otp_user_id]       = 2
    @request.session[:telegram_password] = '1234'

    Redmine2FA::OtpAuth.expects(:generate_telegram_password).returns('5678')
    Redmine2FA::OtpAuth.expects(:send_telegram_password).with('79999999999', '5678')

    get :telegram_resend

    assert_template 'telegram'
    assert_select 'div.flash.notice', text: /SMS confirmation password sent again/
    assert @request.session[:otp_user_id] == 2
    assert @request.session[:telegram_password] == '5678'
    assert @request.session[:telegram_failed_attempts].zero?
  end
end
