module RedmineTwoFa
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationInit
        private

        def password_authentication
          if RedmineTwoFa.switched_off? || @user.locked? || @user.ignore_2fa? || @user.two_factor_authenticable?
            return super
          end

          render 'account/init_2fa'
        end
      end
    end
  end
end
