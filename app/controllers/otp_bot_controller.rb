class OtpBotController < ApplicationController
  unloadable

  skip_before_filter :verify_authenticity_token

  skip_before_filter :check_if_login_required, :check_password_change


  def init
    logger = Rails.env.production? ? Logger.new(Rails.root.join('log/redmine_2fa', 'bot.log')) : Logger.new(STDOUT)

    token = Setting.plugin_redmine_2fa['bot_token']

    unless token.present?
      logger.error 'Telegram Bot Token not found. Please set it in the plugin config web-interface.'
    end

    logger.info 'Telegram Bot: Connecting to telegram...'
    bot      = Telegrammer::Bot.new(token)
    bot_name = bot.me.username

    until bot_name.present?
      logger.error 'Telegram Bot Token is invalid or Telegram API is in downtime. I will try again after minute'

      logger.info 'Telegram Bot: Connecting to telegram...'
      bot      = Telegrammer::Bot.new(token)
      bot_name = bot.me.username
    end


    webhook_url = URI::HTTPS.build({ host: Setting['host_name'], path: '/redmine_2fa/update' }).to_s


    response = bot.set_webhook(webhook_url)

    plugin_settings = Setting.find_by(name: 'plugin_redmine_2fa')

    plugin_settings_hash             = plugin_settings.value
    plugin_settings_hash['bot_name'] = bot_name
    plugin_settings_hash['bot_id']   = bot.me.id
    plugin_settings.value            = plugin_settings_hash

    plugin_settings.save

    redirect_to plugin_settings_path('redmine_2fa'), notice: 'Бот успешно инициализирован'
  end

  def update
    logger = Rails.env.production? ? Logger.new(Rails.root.join('log/redmine_2fa', 'bot-update.log')) : Logger.new(STDOUT)
    logger.debug params

    message = JSON.parse(params[:message].to_json, object_class: OpenStruct)
    message_text = message.text

    if message_text == '/start'
      Redmine2FA::TelegramBotService.new.start(message)
    elsif message_text&.include?('/connect')
      email = message_text.scan(/([^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,})/i)&.flatten&.first
      user  = EmailAddress.find_by(address: email)&.user

      telegram_account = Redmine2FA::TelegramAccount.where(telegram_id: message.from.id).first

      Redmine2FA::Mailer.telegram_connect(user, telegram_account).deliver
    end

    head :ok
  end
end
