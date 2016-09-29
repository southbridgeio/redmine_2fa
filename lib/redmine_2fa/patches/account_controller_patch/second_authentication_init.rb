module Redmine2FA
  module Patches
    module AccountControllerPatch
      module SecondAuthenticationInit
        def user_auth_protocol_confirm
        end

        private

        def password_authentication
          @user = User.find_by_login(params[:username])

          if @user.has_otp_auth? || @user.ignore_2fa?
            super
          else
            if User.try_to_login(params[:username], params[:password]) == @user
              @qr = RQRCode::QRCode.new(@user.provisioning_uri("#{@user.login}@#{Setting.host_name}"),
                                        size: 8, level: :h)
              render 'redmine_2fa_init'
            else
              invalid_credentials
            end
          end
        end
      end
    end
  end
end
