module Redmine2FA
  module Patches
    module UserPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.safe_attributes 'mobile_phone', 'ignore_2fa'
        base.validates_format_of :mobile_phone, with: /\A\d*\z/, allow_blank: true

        base.class_eval do
          unloadable

          has_one_time_password length: 6

          alias_method_chain :update_hashed_password, :otp_auth
        end
      end

      module InstanceMethods
        def update_hashed_password_with_otp_auth
          if two_factor_authenticable?
            salt_password(password) if password
          else
            update_hashed_password_without_otp_auth
          end
        end

        def two_factor_authenticable?
          telegram_authenticable? || sms_authenticable? || google_authenticable?
        end

        def sms_authenticable?
          auth_source&.auth_method_name == 'SMS'
        end

        def telegram_authenticable?
          auth_source&.auth_method_name == 'Telegram'
        end

        def google_authenticable?
          auth_source&.auth_method_name == 'Google Auth'
        end

        def reset_second_auth
          otp_regenerate_secret
          self.auth_source_id = nil
          self.ignore_2fa = false
          save!
        end

        def confirm_mobile_phone(code)
          if mobile_phone.present? && authenticate_otp(code, drift: 120)
            self.mobile_phone_confirmed = true
            save!
          else
            errors[:base] << I18n.t('redmine_2fa.notice.auth_code.invalid')
          end
        end
      end
    end
  end
end
User.send(:include, Redmine2FA::Patches::UserPatch)
