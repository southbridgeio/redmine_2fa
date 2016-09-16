module Redmine2FA
  module TelegramAuth


    def self.send_otp_code(user)
      auth_method_name = user&.auth_source&.auth_method_name

      time = Time.now
      expiration_time = time + 2.minutes
      expiration_time_string = expiration_time.strftime('%H:%M:%S')
      code = user.otp_code(time: time)

      if auth_method_name == 'Telegram'
        telegram_account = user.telegram_account

        if telegram_account.present?
          token = Setting.plugin_redmine_2fa['bot_token']
          bot   = Telegrammer::Bot.new(token)

          message = I18n.t('redmine_2fa.telegram_auth.message',
                           app_title: Setting.app_title, code: code, expiration_time: expiration_time_string)

          bot.send_message(chat_id: telegram_account.telegram_id, text: message)
        end
      else
        puts "AUTH CODE: #{code}"
      end

    end

  end
end
