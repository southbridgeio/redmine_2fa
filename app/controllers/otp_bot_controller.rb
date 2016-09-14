class OtpBotController < ApplicationController
  unloadable

  skip_before_filter :verify_authenticity_token, :check_if_login_required, :check_password_change

  def init
    token = Setting.plugin_redmine_2fa['bot_token']

    bot      = Telegrammer::Bot.new(token)
    bot_name = bot.me.username

    webhook_url = URI::HTTPS.build({ host: Setting['host_name'], path: '/redmine_2fa/update' }).to_s

    response = bot.set_webhook(webhook_url)

    plugin_settings = Setting.find_by(name: 'plugin_redmine_2fa')

    plugin_settings_hash             = plugin_settings.value
    plugin_settings_hash['bot_name'] = bot_name
    plugin_settings_hash['bot_id']   = bot.me.id
    plugin_settings.value            = plugin_settings_hash

    plugin_settings.save

    redirect_to plugin_settings_path('redmine_2fa'), notice: t('redmine_2fa.otp_bot.init.success')

  rescue MultiJson::ParseError

    redirect_to plugin_settings_path('redmine_2fa'), error: t('redmine_2fa.otp_bot.init.error.wrong_token')

  rescue Telegrammer::Errors::ServiceUnavailableError

    redirect_to plugin_settings_path('redmine_2fa'), error: t('redmine_2fa.otp_bot.init.error.api_error')

  end

  ## Telegram Bot Webhook handler

  def update
    logger = Logger.new(Rails.root.join('log/redmine_2fa', 'bot-update.log'))
    logger.debug params

    message      = JSON.parse(params[:message].to_json, object_class: OpenStruct)
    message_text = message.text

    if message_text&.include?('start')
      Redmine2FA::TelegramBotService.new.start(message)
    elsif message_text&.include?('/connect')
      Redmine2FA::TelegramBotService.new.connect(message)
    end

    head :ok
  end
end
