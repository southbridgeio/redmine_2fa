class OtpBotWebhookController < ApplicationController
  unloadable

  skip_before_filter :verify_authenticity_token, :check_if_login_required, :check_password_change

  before_filter :authorize

  ## Telegram Bot Webhook handler

  def update
    logger = Logger.new(Rails.root.join('log/redmine_2fa', 'bot-update.log'))
    logger.debug params

    Redmine2FA::Telegram::BotService.new(params[:message]).call if params[:message].present?

    head :ok
  end

  private

  def authorize
    render_403 unless params[:token] && Redmine2FA.bot_token == params[:token]
  end
end
