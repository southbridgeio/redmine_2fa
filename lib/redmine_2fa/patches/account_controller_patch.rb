require_dependency 'account_controller'

puts "Account Patch"

module Redmine2FA
  module Patches
    module AccountControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :password_authentication, :telegram_auth
        end
      end

      module InstanceMethods

        def telegram_confirm
          if session[:telegram_user_id] && session[:telegram_auth_code]
            user = User.find(session[:telegram_user_id])
            if session[:telegram_auth_code] == params[:telegram_auth_code].to_s
              session[:telegram_user_id]         = nil
              session[:telegram_auth_code]        = nil
              session[:telegram_failed_attempts] = nil
              params[:back_url]                  = session[:telegram_back_url]
              session[:telegram_back_url]        = nil
              successful_authentication(user)
            else
              session[:telegram_failed_attempts] ||= 0
              session[:telegram_failed_attempts] += 1
              if session[:telegram_failed_attempts] >= 3
                regenerate_telegram_auth_code(user)
                flash[:error] = t('redmine_2fa.notice.auth_code.limit_exceeded_failed_attempts')
              else
                flash[:error] = t('redmine_2fa.notice.auth_code.invalid')
              end
              render 'telegram_auth'
            end
          else
            redirect_to '/'
          end
        end

        def telegram_resend
          if session[:telegram_user_id] && session[:telegram_auth_code]
            user = User.find(session[:telegram_user_id])
            regenerate_telegram_auth_code(user)
            flash[:notice] = t('redmine_2fa.notice.auth_code.resent_again')
            render 'telegram_auth'
          else
            redirect_to '/'
          end
        end

        private

        def password_authentication_with_telegram_auth
          user = User.where(login: params[:username].to_s).first
          if user&.auth_source&.auth_method_name == 'Telegram' #&& user.telegram_account.present?
            session[:telegram_back_url] = params[:back_url]
            if User.try_to_login(params[:username], params[:password]) == user
              session[:telegram_user_id] = user.id
              regenerate_telegram_auth_code(user)
              render 'telegram_auth'
            else
              invalid_credentials
            end
          else
            password_authentication_without_telegram_auth
          end
        end

        def regenerate_telegram_auth_code(user)
          session[:telegram_auth_code] = Redmine2FA::TelegramAuth.random_telegram_auth_code
          Redmine2FA::TelegramAuth.send_telegram_auth_code(user.telegram_account&.telegram_id, session[:telegram_auth_code])
          session[:telegram_failed_attempts] = 0
        end

      end

    end
  end
end


AccountController.send(:include, Redmine2FA::Patches::AccountControllerPatch)
