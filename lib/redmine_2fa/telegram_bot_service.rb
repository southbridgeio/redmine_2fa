module Redmine2FA
  class TelegramBotService

    attr_reader :bot, :logger

    def initialize
      @bot    = Telegrammer::Bot.new(Setting.plugin_redmine_2fa['bot_token'])
      @logger = Logger.new(Rails.root.join('log/redmine_2fa', 'bot.log'))
    end


    def start(telegram_message)
      user             = telegram_message.from
      telegram_account = Redmine2FA::TelegramAccount.where(telegram_id: user.id).
          first_or_initialize(username:   user.username,
                              first_name: user.first_name,
                              last_name:  user.last_name)

      if telegram_account.new_record?
        telegram_account.save
        @logger.info "New user #{user.first_name} #{user.last_name} @#{user.username} added!"
      else
        telegram_account.update_columns username:   user.username,
                                        first_name: user.first_name,
                                        last_name:  user.last_name

        telegram_account.activate! unless telegram_account.active?
      end


      message = if telegram_account.user.present?
                  I18n.t('redmine_2fa.redmine_telegram_connections.create.success')
                else
                  I18n.t('redmine_2fa.otp_bot.start.instruction_html')
                end

      @bot.send_message(chat_id: telegram_message.chat.id, text: message, parse_mode: 'HTML')
    end

    def connect(telegram_message)
      message_text = telegram_message.text
      email        = message_text.scan(/([^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,})/i)&.flatten&.first
      user         = EmailAddress.find_by(address: email)&.user

      telegram_account = Redmine2FA::TelegramAccount.where(telegram_id: telegram_message.from.id).first

      if telegram_account.user_id == user.id
        message = I18n.t('redmine_2fa.otp_bot.connect.already_connected')
      else
        message = I18n.t('redmine_2fa.otp_bot.connect.wait_for_email', email: email)

        Redmine2FA::Mailer.telegram_connect(user, telegram_account).deliver
      end

      @bot.send_message(chat_id: telegram_message.chat.id, text: message, parse_mode: 'HTML')

    end

  end
end
