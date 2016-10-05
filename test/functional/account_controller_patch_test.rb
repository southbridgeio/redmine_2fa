require File.expand_path('../../test_helper', __FILE__)

class AccountControllerPatchTest < ActionController::TestCase
  tests AccountController

  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    Redmine2FA.stubs(:switched_on).returns(true)
    @user = User.find(2) # jsmith
  end

  context 'user without 2fa' do
    setup { post :login, username: 'jsmith', password: 'jsmith', back_url: 'http://test.host/' }

    context 'prepare' do
      should set_session[:otp_user_id].to(2)
      should set_session[:otp_back_url].to('http://test.host/')
    end

    context 'init' do
      should render_template('account/init_2fa')
      should 'set qr instance variable' do
        assert_not_nil assigns(:qr)
      end
    end
  end

  context 'user with 2fa' do

    context 'google auth' do
      setup do
        User.any_instance.stubs(:auth_source).returns(auth_sources(:google_auth))
        post :login, username: 'jsmith', password: 'jsmith'
      end
      should render_template('account/otp')
    end

    context 'telegram' do

    end

    context 'sms'

    setup do
      @user.auth_source = auth_sources(:google_auth)

      # Redmine2FA::CodeSender.any_instance.expects(:send_code)


    end



    context 'with errors' do

    end

  end



  context 'confirm one time password' do

  end
end
