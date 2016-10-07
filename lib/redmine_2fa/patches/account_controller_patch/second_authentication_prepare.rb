module Redmine2FA
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationPrepare
        private

        def password_authentication
          @user = User.find_by_login(params[:username])

          if @user && User.try_to_login(params[:username], params[:password])
            set_otp_session
            super
          else
            invalid_credentials
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
