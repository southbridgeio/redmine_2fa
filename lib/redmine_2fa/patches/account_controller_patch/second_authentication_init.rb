module Redmine2FA
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationInit
        private

        def password_authentication
          if Redmine2FA.switched_off? || @user.ignore_2fa? || @user.two_factor_authenticable?
            super
          else
            @qr = RQRCode::QRCode.new(@user.provisioning_uri("#{@user.login}@#{Setting.host_name}"), size: 8, level: :h)
            render 'account/init_2fa'
          end
        end
      end
    end
  end
end
