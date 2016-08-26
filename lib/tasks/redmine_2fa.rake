namespace :redmine_2fa do
  namespace :telegram do
    # bundle exec rake redmine_2fa:telegram:bot PID_DIR='tmp/pids'
    task bot: :environment do
      LOG   = Rails.env.production? ? Logger.new(Rails.root.join('log/redmine_2fa', 'bot.log')) : Logger.new(STDOUT)

      token = Setting.plugin_redmine_2fa['bot_token']

      unless token.present?
        LOG.error 'Telegram Bot Token not found. Please set it in the plugin config web-interface.'
        exit
      end

      LOG.info 'Telegram Bot: Connecting to telegram...'
      bot      = Telegrammer::Bot.new(token)
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
          next unless message.is_a?(Telegrammer::DataTypes::Message) # Update for telegrammer gem 0.8.0
          if message.text == '/start'
            user   = message.from
            t_user = Redmine2FA::TelegramAccount.where(telegram_id: user.id).first_or_initialize(username:   user.username,
                                                                                         first_name: user.first_name,
                                                                                         last_name:  user.last_name)
            if t_user.new_record?
              t_user.save
              bot.send_message(chat_id: message.chat.id, text: "Hello, #{user.first_name}! I've added your profile for Redmine notifications.")
              LOG.info "#{bot_name}: new user #{user.first_name} #{user.last_name} @#{user.username} added!"
            else
              t_user.update_columns username:   user.username,
                                    first_name: user.first_name,
                                    last_name:  user.last_name
              if t_user.active?
                bot.send_message(chat_id: message.chat.id, text: "Hello, #{user.first_name}! I've updated your profile for Redmine notifications.")
              else
                t_user.activate!
                bot.send_message(chat_id: message.chat.id, text: "Hello again, #{user.first_name}! I've activated your profile for Redmine notifications.")
              end
            end
          end
        rescue Exception => e
          LOG.error "UPDATE ERROR #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
        end
      end


    end
  end

end
