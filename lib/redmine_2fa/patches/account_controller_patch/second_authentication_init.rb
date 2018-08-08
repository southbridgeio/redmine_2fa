module Redmine2FA
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationInit
        private

        def password_authentication
          if Redmine2FA.switched_off? || @user.locked? || @user.ignore_2fa? || @user.two_factor_authenticable?
            super
          else
            begin
              qr_size ||= 10
              @qr = RQRCode::QRCode.new(@user.provisioning_uri("#{@user.login}", issuer: "#{Setting.host_name}"), size: qr_size, level: :h)
              render 'account/init_2fa'
            rescue RQRCode::QRCodeRunTimeError => e
              retry unless (qr_size += 1) > 20
              raise e
            end
          end
        end
      end
    end
  end
end
