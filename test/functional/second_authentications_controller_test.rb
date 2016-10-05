require File.expand_path('../../test_helper', __FILE__)

class SecondAuthenticationsControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user = User.find(2)

    User.any_instance.stubs(:otp_code)

    @auth_source = auth_sources(:google_auth)
  end

  context 'confirm' do
    should 'update auth source' do
      @request.session[:otp_user_id] = @user.id

      Redmine2FA::CodeSender.any_instance.expects(:send_code)

      put :update, auth_source_id: @auth_source.id

      assert_template 'account/otp'

      @user.reload

      assert_equal @auth_source.id, @user.auth_source_id
    end

    context 'unauthorized' do
      should 'not update auth source' do
        @request.session[:otp_user_id] = nil

        put :update, auth_source_id: @auth_source.id

        @user.reload

        assert_not_equal @auth_source.id, @user.auth_source_id
      end
    end


  end

  context 'reset' do

  end

end
