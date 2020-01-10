module RedmineTwoFa
  module Patches
    module AccountControllerPatch
      module ConfirmMethods
        def self.included(base) # :nodoc:
          base.send(:include, InstanceMethods)

          base.class_eval do
            unloadable

            before_action :set_user_from_session, only: [:confirm_otp, :confirm_2fa]
          end
        end

        module InstanceMethods
          def confirm_2fa
            unless RedmineTwoFa.active_protocols.keys.include?(params[:protocol])
              render_403
              return
            end

            protocol = RedmineTwoFa::Protocols[params[:protocol]]

            if protocol.bypass?
              @user.update!(ignore_2fa: true, two_fa: nil)
              reset_otp_session
              successful_authentication(@user)
            else
              update_two_fa
              send_code
              render 'account/otp'
            end
          end

          def confirm_otp
            if @user.authenticate_otp(params[:otp_code], drift: 120)
              update_two_fa if @user.two_fa.nil?
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

          def send_code
            protocol.send_code(@user)
          end

          def set_user_from_session
            if session[:otp_user_id]
              @user = User.find(session[:otp_user_id])
            else
              deny_access
            end
          end

          def update_two_fa
            @user.update_columns(two_fa: params[:protocol]) if params[:protocol]
          end

          def protocol
            @user.two_fa_protocol
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
