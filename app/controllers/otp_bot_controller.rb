class OtpBotController < ApplicationController
  unloadable


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

    render :nothing, status: :ok
  end
end
