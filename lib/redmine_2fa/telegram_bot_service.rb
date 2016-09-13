module Redmine2FA
  class TelegramBotService

    attr_reader :bot, :logger

    def initialize
      @bot    = Telegrammer::Bot.new(Setting.plugin_redmine_2fa['bot_token'])
      @logger = Logger.new(Rails.root.join('log/redmine_2fa', 'bot.log'))
    end


    def start(message)
      user             = message.from
      telegram_account = Redmine2FA::TelegramAccount.where(telegram_id: user.id).
          first_or_initialize(username:   user.username,
                              first_name: user.first_name,
                              last_name:  user.last_name)

      if telegram_account.new_record?
        telegram_account.save
        @bot.send_message(chat_id: message.chat.id, text: "Hello, #{user.first_name}! I've added your profile for Redmine 2FA.")
        logger.info "New user #{user.first_name} #{user.last_name} @#{user.username} added!"
      else
        telegram_account.update_columns username:   user.username,
                                        first_name: user.first_name,
                                        last_name:  user.last_name
        if telegram_account.active?
          @bot.send_message(chat_id: message.chat.id, text: "Hello, #{user.first_name}! I've updated your profile for Redmine 2FA.")
        else
          telegram_account.activate!
          @bot.send_message(chat_id: message.chat.id, text: "Hello again, #{user.first_name}! I've activated your profile for Redmine 2FA.")
        end
      end
    end

    def connect(message)
      message_text = message.text
      email = message_text.scan(/([^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,})/i)&.flatten&.first
      user  = EmailAddress.find_by(address: email)&.user

      telegram_account = Redmine2FA::TelegramAccount.where(telegram_id: message.from.id).first

      Redmine2FA::Mailer.telegram_connect(user, telegram_account).deliver
    end

  end
end
