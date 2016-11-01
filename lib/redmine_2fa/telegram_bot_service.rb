require 'telegrammer'

module Redmine2FA
  module Telegram
    class BotService
      EMAIL_REGEXP = /([^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,})/i

      attr_reader :bot, :logger, :command

      def initialize(command)
        @bot     = Telegrammer::Bot.new(Redmine2FA.bot_token)
        @logger  = Logger.new(Rails.root.join('log/redmine_2fa', 'bot.log'))
        @command = command.is_a?(Telegrammer::DataTypes::Message) ? command : Telegrammer::DataTypes::Message.new(command)
      end

      def call
        Redmine2FA.set_locale

        command_text = command.text

        if command_text&.include?('start')
          start
        elsif command_text&.include?('/connect')
          connect
        end
      end

      def start
        update_account

        update_auth_source if account.user.present? && account.user.auth_source.nil?

        message = if account.user.present?
                    I18n.t('redmine_2fa.redmine_telegram_connections.create.success')
                  else
                    I18n.t('redmine_2fa.otp_bot.start.instruction_html')
                  end

        send_message(command.chat.id, message)
      end

      def connect
        message_text = command.text
        email        = message_text.scan(EMAIL_REGEXP)&.flatten&.first
        redmine_user = EmailAddress.find_by(address: email)&.user

        return user_not_found if redmine_user.nil?

        if account.user_id == redmine_user.id
          message = I18n.t('redmine_2fa.otp_bot.connect.already_connected')
        else
          message = I18n.t('redmine_2fa.otp_bot.connect.wait_for_email', email: email)

          TelegramCommon::Mailer.telegram_connect(redmine_user, account).deliver
        end

        send_message(command.chat.id, message)
      end

      private

      def user_not_found
        # TODO: implement account block for many trials
        send_message(command.chat.id, 'User not found')
      end

      def user
        command.from
      end

      def account
        @account ||= fetch_account
      end

      def fetch_account
        ::TelegramCommon::Account.where(telegram_id: user.id).first_or_initialize
      end

      def update_account
        account.assign_attributes username:   user.username,
                                  first_name: user.first_name,
                                  last_name:  user.last_name,
                                  active:     true

        write_log_about_new_user if account.new_record?

        account.save!
      end

      def update_auth_source
        account.user.update auth_source_id: Redmine2FA::AuthSource::Telegram.first&.id
      end

      def write_log_about_new_user
        logger.info "New telegram_user #{user.first_name} #{user.last_name} @#{user.username} added!"
      end

      def send_message(chat_id, message)
        bot.send_message(chat_id: chat_id, text: message, parse_mode: 'HTML')
      end
    end
  end
end
