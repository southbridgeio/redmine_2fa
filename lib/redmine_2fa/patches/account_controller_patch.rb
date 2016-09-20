require_dependency 'account_controller'

module Redmine2FA
  module Patches
    module AccountControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :password_authentication, :otp_code
        end
      end

      module InstanceMethods

        def otp_code_confirm
          if session[:otp_user_id]
            @user = User.find(session[:otp_user_id])
            if @user.authenticate_otp(params[:otp_code], drift: 120)
              params[:back_url]             = session[:otp_back_url]
              session[:otp_user_id]         = nil
              session[:otp_failed_attempts] = nil
              session[:otp_back_url]        = nil
              successful_authentication(@user)
            else
              session[:otp_failed_attempts] ||= 0
              session[:otp_failed_attempts] += 1
              if session[:otp_failed_attempts] >= 3
                regenerate_otp_code(@user)
                flash[:error] = t('redmine_2fa.notice.auth_code.limit_exceeded_failed_attempts')
              else
                @hide_countdown = true
                flash[:error] = t('redmine_2fa.notice.auth_code.invalid')
              end
              render 'otp_code'
            end
          else
            redirect_to '/'
          end
        end

        def otp_code_resend
          if session[:otp_user_id]
            @user = User.find(session[:otp_user_id])
            regenerate_otp_code(@user)
            respond_to do |format|
              format.html do
                flash[:notice] = t('redmine_2fa.notice.auth_code.resent_again')
                render 'otp_code'
              end
              format.js
            end
          else
            redirect_to '/'
          end
        end

        private

        def password_authentication_with_otp_code
          @user = User.where(login: params[:username].to_s).first
          if @user&.auth_source&.auth_method_name == 'Telegram'
            session[:otp_back_url] = params[:back_url]
            if User.try_to_login(params[:username], params[:password]) == @user
              session[:otp_user_id] = @user.id
              regenerate_otp_code(@user)
              render 'otp_code'
            else
              invalid_credentials
            end
          else
            password_authentication_without_otp_code
          end
        end

        def regenerate_otp_code(user)
          Redmine2FA::TelegramAuth.send_otp_code(user)
          session[:otp_failed_attempts] = 0
        end

      end

    end
  end
end


AccountController.send(:include, Redmine2FA::Patches::AccountControllerPatch)
