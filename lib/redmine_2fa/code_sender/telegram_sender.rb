module Redmine2FA
  class CodeSender::TelegramSender < CodeSender
    attr_reader :errors, :user

    def initialize(user)
      @user = user
      @telegram_account = user.telegram_account
      @errors = []
    end

    def send_message
      if @telegram_account.present? && @telegram_account.active?
        token = Redmine2FA.bot_token
        bot   = Telegrammer::Bot.new(token)

        message = I18n.t('redmine_2fa.telegram_auth.message',
                         app_title: Setting.app_title, code: code, expiration_time: timestamp)

        bot.send_message(chat_id: @telegram_account.telegram_id, text: message)
      end
    rescue Telegrammer::Errors::BadRequestError => e
      errors << "Telegram Bot API: #{e.message}"
    end
  end
end
