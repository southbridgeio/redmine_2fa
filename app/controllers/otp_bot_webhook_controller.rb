class OtpBotWebhookController < ApplicationController
  unloadable

  skip_before_filter :verify_authenticity_token, :check_if_login_required, :check_password_change


  before_filter :authorize

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

  def authorize
    render_403 unless params[:token] && Redmine2FA.bot_token == params[:token]

  end


end
