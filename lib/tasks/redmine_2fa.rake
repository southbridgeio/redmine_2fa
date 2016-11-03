namespace :redmine_2fa do
  namespace :common do
    # bundle exec rake redmine_2fa:common:migrate
    task migrate: :environment do
      Redmine2FA::TelegramAccount.find_each do |telegram_account|
        TelegramCommon::Account.where(telegram_id: telegram_account.telegram_id)
          .first_or_create(telegram_account.slice(:user_id, :first_name, :last_name, :username, :active))
      end
    end
  end

  namespace :telegram do
    # bundle exec rake redmine_2fa:telegram:bot PID_DIR='tmp/pids'
    task bot: :environment do
      LOG = Rails.env.production? ? Logger.new(Rails.root.join('log/redmine_2fa', 'bot.log')) : Logger.new(STDOUT)

      token = Redmine2FA.bot_token

      unless token.present?
        LOG.error 'Telegram Bot Token not found. Please set it in the plugin config web-interface.'
        exit
      end

      LOG.info 'Telegram Bot: Connecting to telegram...'
      bot = Telegrammer::Bot.new(token)
      bot.set_webhook('') # reset webhook
      bot_name = bot.me.username

      until bot_name.present?
        LOG.error 'Telegram Bot Token is invalid or Telegram API is in downtime. I will try again after minute'
        sleep 60

        LOG.info 'Telegram Bot: Connecting to telegram...'
        bot      = Telegrammer::Bot.new(token)
        bot_name = bot.me.username
      end

      plugin_settings = Setting.find_by(name: 'plugin_redmine_2fa')

      plugin_settings_hash             = plugin_settings.value
      plugin_settings_hash['bot_name'] = bot_name
      plugin_settings_hash['bot_id']   = bot.me.id
      plugin_settings.value            = plugin_settings_hash

      plugin_settings.save

      LOG.info "#{bot_name}: connected"
      LOG.info "#{bot_name}: waiting for new messages..."

      bot.get_updates(fail_silently: false) do |message|
        begin
          next unless message.is_a?(Telegrammer::DataTypes::Message)
          TelegramCommon::Bot.new(Redmine2FA.bot_token, message).call

        rescue StandardError => e
          LOG.error "UPDATE ERROR #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
        end
      end
    end
  end
end
