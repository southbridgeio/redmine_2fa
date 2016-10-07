class RedmineTelegramConnectionsController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required, :check_password_change

  def create
    @user = User.find(params[:user_id])

    @telegram_account = Redmine2FA::TelegramAccount.find_by(telegram_id: params[:telegram_id])

    notice = connect_telegram_account_to_user

    redirect_to home_path, notice: notice
  end

  def connect_telegram_account_to_user
    if @user.mail == params[:user_email] && params[:token] == @telegram_account.token
      @user.telegram_account = @telegram_account
      @user.save
    end

    if @user.telegram_account.present?
      t('redmine_2fa.redmine_telegram_connections.create.success')
    else
      t('redmine_2fa.redmine_telegram_connections.create.error')
    end
  end
end
