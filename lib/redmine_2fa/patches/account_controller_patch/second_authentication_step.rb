module Redmine2FA
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationStep

        private

        def password_authentication
          if !@user.ignore_2fa? && @user.has_otp_auth?
            send_code
            flash[:error] = sender.errors.join(', ') if sender.errors.present?
            render 'account/otp'
          else
            super
          end
        end

        def send_code
          sender.send_code
        end

        def sender
          @sender ||= Redmine2FA::CodeSender.new(@user)
        end

      end
    end
  end
end
