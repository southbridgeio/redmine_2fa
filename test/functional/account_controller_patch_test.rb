require File.expand_path('../../test_helper', __FILE__)

class AccountControllerPatchTest < ActionController::TestCase
  tests AccountController

  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user = User.find(2) # jsmith
    Redmine2FA.stubs(:active_protocols).returns(Redmine2FA::AVAILABLE_PROTOCOLS)
  end

  context 'user without 2fa' do
    context 'with valid login data' do
      setup { post :login, username: 'jsmith', password: 'jsmith', back_url: 'http://test.host/' }

      context 'prepare' do
        should set_session[:otp_user_id].to(2)
        should set_session[:otp_back_url].to('http://test.host/')
        should 'set user instance variable' do
          assert_equal @user, assigns(:user)
        end
      end

      context 'init' do
        should render_template('account/init_2fa')
        should 'set qr instance variable' do
          assert_not_nil assigns(:qr)
        end
      end
    end

    context 'with invalid password' do
      setup do
        AccountController.any_instance.expects(:invalid_credentials)
        post :login, username: 'jsmith', password: 'wrong', back_url: 'http://test.host/'
      end

      context 'prepare' do
        should_not set_session[:otp_user_id].to(2)
        should_not set_session[:otp_back_url].to('http://test.host/')
      end
    end

    context 'with invalid login' do
      setup do
        AccountController.any_instance.expects(:invalid_credentials)
        post :login, username: 'invalid', password: 'wrong', back_url: 'http://test.host/'
      end

      context 'prepare' do
        should_not set_session[:otp_user_id].to(2)
        should_not set_session[:otp_back_url].to('http://test.host/')
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

  context 'confirm auth source' do
    setup do
      User.any_instance.stubs(:otp_code)

      @auth_source = auth_sources(:google_auth)
    end

    should 'update auth source' do
      @request.session[:otp_user_id] = @user.id

      Redmine2FA::CodeSender.any_instance.expects(:send_code)

      post :confirm_2fa, protocol: @auth_source.protocol

      assert_template 'account/otp'

      @user.reload

      assert_equal @auth_source.id, @user.auth_source_id
    end

    context 'unauthorized' do
      should 'not update auth source' do
        @request.session[:otp_user_id] = nil

        post :confirm_2fa, protocol: @auth_source.protocol

        @user.reload

        assert_not_equal @auth_source.id, @user.auth_source_id
      end
    end
  end

  context 'confirm one time password' do
  end
end
