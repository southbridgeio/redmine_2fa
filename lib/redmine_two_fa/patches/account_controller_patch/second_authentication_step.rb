module RedmineTwoFa
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationStep
        private

        def password_authentication
          if RedmineTwoFa.switched_on? && !@user.locked? && !@user.ignore_2fa? && @user.two_factor_authenticable?
            send_code
            flash[:error] = sender.errors.join(', ') if sender.errors.present?
            render(@user.two_fa&.name == 'Telegram' ? 'account/telegram_login' : 'account/otp')
          else
            super
          end
        end

        def send_code
          sender.send_code
        end

        def sender
          @sender ||= RedmineTwoFa::CodeSender.new(@user)
        end
      end
    end
  end
end
