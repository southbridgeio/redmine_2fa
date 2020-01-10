module RedmineTwoFa
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationPrepare
        private

        def password_authentication
          @user = User.try_to_login(params[:username], params[:password], false)

          if @user.nil?
            invalid_credentials
          elsif @user.new_record?
            onthefly_creation_failed(@user, { login: @user.login, auth_source_id: @user.auth_source_id })
          else
            set_otp_session
            super
          end
        end

        def set_otp_session
          session[:otp_back_url] = params[:back_url]
          session[:otp_user_id]  = @user.id
        end
      end
    end
  end
end
