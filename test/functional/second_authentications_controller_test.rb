require File.expand_path('../../test_helper', __FILE__)

class SecondAuthenticationsControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user_self = User.find(2) #jsmith
    @user_admin = User.find(1) #admin
    @user_other = User.find(3) #dlopper

    @auth_source = auth_sources(:google_auth)
  end

  context 'reset' do
    setup do
      @user_self.auth_source = @auth_source
      @user_self.save
    end

    should 'current user is self' do
      User.current = @user_self
      @request.session[:user_id] = @user_self.id
      @request.env["HTTP_REFERER"] = 'test'

      assert_equal @user_self.auth_source, @auth_source

      delete :destroy, id: @user_self.id
      assert_response 302

      @user_self.reload
      assert_equal @user_self.auth_source_id, nil
    end

    should 'current user is admin' do
      User.current = @user_admin
      @request.session[:user_id] = @user_admin.id
      @request.env["HTTP_REFERER"] = 'test'

      assert_equal @user_self.auth_source, @auth_source

      delete :destroy, id: @user_self.id
      assert_response 302

      @user_self.reload
      assert_equal @user_self.auth_source_id, nil
    end

    should 'current user is not admin' do
      User.current = @user_other
      @request.session[:user_id] = @user_other.id
      assert_equal @user_self.auth_source, @auth_source
      delete :destroy, id: @user_self.id
      assert_response 403

      @user_self.reload
      assert_equal @user_self.auth_source, @auth_source
    end
  end
end
