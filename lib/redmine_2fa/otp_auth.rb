module Redmine2FA
  class OtpAuth

    def send_otp_code(user)
      time = Time.now
      expiration_time = time + 2.minutes
      expiration_time_string = expiration_time.strftime('%H:%M:%S')
      code = user.otp_code(time: time)
      
      auth_method_name = user&.auth_source&.auth_method_name

      if auth_method_name == 'Telegram'
        telegram_account = user.telegram_account

        if telegram_account.present? && telegram_account.active?
          token = Setting.plugin_redmine_2fa['bot_token']
          bot   = Telegrammer::Bot.new(token)

          message = I18n.t('redmine_2fa.telegram_auth.message',
                           app_title: Setting.app_title, code: code, expiration_time: expiration_time_string)

          bot.send_message(chat_id: telegram_account.telegram_id, text: message)
        end
      elsif auth_method_name == 'SMS'
        phone = user.mobile_phone
        phone = phone.gsub(/[^-+0-9]+/,'') # Additional phone sanitizing
        command = Redmine2FA::Configuration.sms_command
        command = command.sub('%{phone}', phone).sub('%{password}', code)
        system command
      end
      
      code
    end
  end
end
