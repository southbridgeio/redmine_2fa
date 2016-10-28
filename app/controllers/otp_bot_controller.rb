class OtpBotController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :set_bot

  def create # init
    set_bot_webhook
    update_plugin_settings(@bot.me)
    redirect_to plugin_settings_path('redmine_2fa'), notice: t('redmine_2fa.otp_bot.init.success')
  end

  def destroy # reset
    reset_bot_webhook
    reset_telegram_authentications
    redirect_to plugin_settings_path('redmine_2fa'), notice: t('redmine_2fa.otp_bot.reset.success')
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
    @token = Redmine2FA.bot_token
    @bot = Telegrammer::Bot.new(@token)
  rescue MultiJson::ParseError
    render_error message: t('redmine_2fa.otp_bot.init.error.wrong_token'), status: 406
  rescue Telegrammer::Errors::ServiceUnavailableError
    render_error message: t('redmine_2fa.otp_bot.init.error.api_error'), status: 503
  end

  def set_bot_webhook
    webhook_url = URI::HTTPS.build(host: Setting['host_name'],
                                   path: "/redmine_2fa/bot/#{@token}/update").to_s

    @bot.set_webhook(webhook_url)
  end

  def reset_bot_webhook
    @bot.set_webhook('')
  end

  def reset_telegram_authentications
    auth_source = Redmine2FA::AuthSource::Telegram.first
    User.where(auth_source_id: auth_source.id).update_all(auth_source_id: nil)
  end
end
