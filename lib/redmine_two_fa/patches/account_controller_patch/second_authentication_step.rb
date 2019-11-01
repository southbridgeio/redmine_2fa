module RedmineTwoFa
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationStep
        private

        def password_authentication
          if RedmineTwoFa.switched_on? && !@user.locked? && !@user.ignore_2fa? && @user.two_factor_authenticable?
            send_code
            render(protocol.second_step_partial)
          else
            super
          end
        end
      end
    end
  end
end
