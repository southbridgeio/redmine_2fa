module Redmine2FA
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationInit


        private


        def password_authentication

          if Redmine2FA.switched_off || @user.ignore_2fa? || @user.has_otp_auth?
            super
          else
            @qr = RQRCode::QRCode.new(@user.provisioning_uri("#{@user.login}@#{Setting.host_name}"),
                                      size: 8, level: :h)
            render 'redmine_2fa_init'
          end

        end


      end
    end
  end
end
