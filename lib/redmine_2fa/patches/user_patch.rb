module Redmine2FA
  module Patches
    module UserPatch
      def self.included(base) # :nodoc:

        base.class_eval do
          unloadable

          has_one :telegram_account, dependent: :destroy, class_name: 'Redmine2FA::TelegramAccount'

        end
      end

    end
  end

end
User.send(:include, Redmine2FA::Patches::UserPatch)
