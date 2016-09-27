module Redmine2FA
  module Patches
    module UserPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.safe_attributes 'mobile_phone'
        base.validates_format_of :mobile_phone, with: /\A[-+0-9]*\z/, allow_blank: true

        base.class_eval do
          unloadable

          has_one :telegram_account, dependent: :destroy, class_name: 'Redmine2FA::TelegramAccount'

          has_one_time_password length: 6

          alias_method_chain :update_hashed_password, :sms_auth
        end
      end

      module InstanceMethods
        def update_hashed_password_with_sms_auth
          if has_telegram_auth?  || has_sms_auth? || has_google_auth?
            salt_password(password) if password
          else
            update_hashed_password_without_sms_auth
          end
        end

        def has_otp_auth?
          has_telegram_auth? && telegram_account.present? ||
              has_sms_auth? || has_google_auth?
        end

        def has_sms_auth?
          auth_source&.auth_method_name == 'SMS'
        end

        def has_telegram_auth?
          auth_source&.auth_method_name == 'Telegram'
        end

        def has_google_auth?
          auth_source&.auth_method_name == 'Google Auth'
        end
      end
    end
  end
end
User.send(:include, Redmine2FA::Patches::UserPatch)
