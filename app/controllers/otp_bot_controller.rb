class OtpBotController < ApplicationController
  unloadable

  # before_filter :authorize, :except => [:update]
  skip_before_filter :verify_authenticity_token, :check_if_login_required, :check_password_change, only: [:update]
  before_filter :set_bot, only: [:init, :deactivate]

  def init
    set_bot_webhook
    update_plugin_settings(@bot.me)
    redirect_to plugin_settings_path('redmine_2fa'), notice: t('redmine_2fa.otp_bot.init.success')
  end

  def deactivate
    reset_bot_webhook
    deactivate_telegram_accounts
    redirect_to plugin_settings_path('redmine_2fa'), notice: t('redmine_2fa.otp_bot.deactivate.success')
  end

  ## Telegram Bot Webhook handler

  def update
    logger = Logger.new(Rails.root.join('log/redmine_2fa', 'bot-update.log'))
    logger.debug params

    if params[:message].present?
      message      = JSON.parse(params[:message].to_json, object_class: OpenStruct)
      message_text = message.text

      if message_text&.include?('start')
        Redmine2FA::TelegramBotService.new.start(message)
      elsif message_text&.include?('/connect')
        Redmine2FA::TelegramBotService.new.connect(message)
      end
    end

    head :ok
  end

  private


  def update_plugin_settings(bot_info)
    plugin_settings = Setting.find_by(name: 'plugin_redmine_2fa')

    plugin_settings_hash             = plugin_settings.value
    plugin_settings_hash['bot_name'] = bot_info.username
    plugin_settings_hash['bot_id']   = bot_info.id
    plugin_settings.value            = plugin_settings_hash

    plugin_settings.save
  end

  def set_bot
    token = Setting.plugin_redmine_2fa['bot_token']
    @bot  = Telegrammer::Bot.new(token)
  rescue MultiJson::ParseError
    render_error :message => t('redmine_2fa.otp_bot.init.error.wrong_token'), :status => 406
  rescue Telegrammer::Errors::ServiceUnavailableError
    render_error :message => t('redmine_2fa.otp_bot.init.error.api_error'), :status => 503
  end

  def set_bot_webhook
    webhook_url = URI::HTTPS.build({ host: Setting['host_name'], path: '/redmine_2fa/update' }).to_s

    @bot.set_webhook(webhook_url)
  end

  def reset_bot_webhook
    @bot.set_webhook('')
  end

  def deactivate_telegram_accounts
    Redmine2FA::TelegramAccount.update_all(active: false)
  end
end
