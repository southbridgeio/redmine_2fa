module RedmineTwoFa
  module Patches
    module UserPatch
      def self.included(base)
        base.prepend InstanceMethods
        base.safe_attributes 'mobile_phone'
        base.safe_attributes 'api_allowed', 'ignore_2fa', if: ->(_user, user) { user.admin? }
        base.validates_format_of :mobile_phone, with: /\A\d*\z/, allow_blank: true

        base.class_eval do
          unloadable

          has_one_time_password length: 6

          has_one :telegram_connection, class_name: 'RedmineTwoFa::TelegramConnection'
        end
      end

      module InstanceMethods
        def update_hashed_password
          if two_factor_authenticable?
            salt_password(password) if password
          else
            super
          end
        end

        def two_factor_authenticable?
          two_fa
        end

        def sms_authenticable?
          two_fa&.auth_method_name == 'SMS'
        end

        def telegram_authenticable?
          two_fa&.auth_method_name == 'Telegram'
        end

        def google_authenticable?
          two_fa&.auth_method_name == 'Google Auth'
        end

        def reset_second_auth
          otp_regenerate_secret
          self.class.transaction do
            self.telegram_connection&.destroy!
            self.two_fa_id = nil
            self.ignore_2fa = false
            save!
          end
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
User.send(:include, RedmineTwoFa::Patches::UserPatch)
