module Redmine2FA
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationStep


        private

        def password_authentication
          if !@user.ignore_2fa? && @user.has_otp_auth?
            send_code(@user)
            render 'redmine_2fa'
          else
            super
          end
        end

        def send_code(user)
          Redmine2FA::OtpAuth.new.send_code(user)
          session[:otp_failed_attempts] = 0
        end

      end
    end
  end
end
