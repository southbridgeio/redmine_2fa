require File.expand_path('../../test_helper', __FILE__)

class AccountControllerPatchTest < ActionController::TestCase
  tests AccountController

  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user = User.find(2) # jsmith
    RedmineTwoFa.stubs(:active_protocols).returns(RedmineTwoFa::AVAILABLE_PROTOCOLS)
  end

  context 'user without 2fa' do
    context 'with valid login data' do
      setup do
        if Rails.version < '5.0'
          post :login, username: 'jsmith', password: 'jsmith', back_url: 'http://test.host/'
        else
          post :login, params: { username: 'jsmith', password: 'jsmith', back_url: 'http://test.host/' }
        end
      end

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
        if Rails.version < '5.0'
          post :login, username: 'jsmith', password: 'wrong', back_url: 'http://test.host/'
        else
          post :login, params: { username: 'jsmith', password: 'wrong', back_url: 'http://test.host/' }
        end
      end

      context 'prepare' do
        should_not set_session[:otp_user_id].to(2)
        should_not set_session[:otp_back_url].to('http://test.host/')
      end
    end

    context 'with invalid login' do
      setup do
        AccountController.any_instance.expects(:invalid_credentials)
        if Rails.version < '5.0'
          post :login, username: 'invalid', password: 'wrong', back_url: 'http://test.host/'
        else
          post :login, params: { username: 'invalid', password: 'wrong', back_url: 'http://test.host/' }
        end
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
        User.any_instance.stubs(:two_fa).returns(auth_sources(:google_auth))
        if Rails.version < '5.0'
          post :login, username: 'jsmith', password: 'jsmith'
        else
          post :login, params: { username: 'jsmith', password: 'jsmith' }
        end
      end
      should render_template('account/otp')
    end

    context 'telegram' do
    end

    context 'sms'

    setup do
      @user.two_fa = auth_sources(:google_auth)

      # RedmineTwoFa::CodeSender.any_instance.expects(:send_code)
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

      RedmineTwoFa::Protocols::SMS.any_instance.expects(:send_code)

      if Rails.version < '5.0'
        post :confirm_2fa, protocol: @auth_source.protocol
      else
        post :confirm_2fa, params: { protocol: @auth_source.protocol }
      end

      assert_template 'account/otp'

      @user.reload

      assert_equal @auth_source.id, @user.two_fa_id
    end

    context 'unauthorized' do
      should 'not update auth source' do
        @request.session[:otp_user_id] = nil

        if Rails.version < '5.0'
          post :confirm_2fa, protocol: @auth_source.protocol
        else
          post :confirm_2fa, params: { protocol: @auth_source.protocol }
        end

        @user.reload

        assert_not_equal @auth_source.id, @user.two_fa_id
      end
    end
  end

  context 'confirm one time password' do
  end
end