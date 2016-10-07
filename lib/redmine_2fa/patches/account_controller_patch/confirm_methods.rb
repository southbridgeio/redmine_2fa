module Redmine2FA
  module Patches
    module AccountControllerPatch
      module ConfirmMethods
        def self.included(base) # :nodoc:
          base.send(:include, InstanceMethods)

          base.class_eval do
            unloadable

            before_filter :set_user_from_session, only: [:confirm_otp, :confirm_2fa]
          end
        end

        module InstanceMethods
          def confirm_2fa
            if params[:auth_source_id] == 'disabled'
              @user.update!(ignore_2fa: true)
              reset_otp_session
              successful_authentication(@user)
            else
              @user.update!(auth_source_id: params[:auth_source_id]) if AuthSource.exists?(params[:auth_source_id])
              Redmine2FA::CodeSender.new(@user).send_code
              render 'account/otp'
            end
          end

          def confirm_otp
            if @user.authenticate_otp(params[:otp_code], drift: 120)
              reset_otp_session
              successful_authentication(@user)
            else
              increment_failed_attempts
              if session[:otp_failed_attempts] >= 3
                send_code
                flash[:error] = t('redmine_2fa.notice.auth_code.limit_exceeded_failed_attempts')
              else
                @hide_countdown = true
                flash[:error]   = t('redmine_2fa.notice.auth_code.invalid')
              end
              render 'account/otp'
            end
          end

          private

          def set_user_from_session
            if session[:otp_user_id]
              @user = User.find(session[:otp_user_id])
            else
              deny_access
            end
          end

          def send_code
            sender.send_code
          end

          def sender
            @sender ||= Redmine2FA::CodeSender.new(@user)
          end

          def reset_otp_session
            params[:back_url] = session[:otp_back_url]
            session.delete(:otp_user_id)
            session.delete(:otp_failed_attempts)
            session.delete(:otp_back_url)
          end

          def increment_failed_attempts
            session[:otp_failed_attempts] ||= 0
            session[:otp_failed_attempts] += 1
          end
        end
      end
    end
  end
end
