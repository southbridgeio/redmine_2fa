module Redmine2FA
  module JWT
    class TelegramStrategy
      def call(token, user)
        message = "#{Setting.protocol}://#{Setting.host_name}/jwt/check"
        RedmineBots::Telegram::Bot::MessageSender.call(bot_token: bot_token, message: token, chat_id: chat_id(user))
      end

      private

      def bot_token
        Setting.plugin_redmine_bots['telegram_bot_token']
      end

      def chat_id(user)
        user.telegram_account.telegram_id
      end
    end
  end
end
