class RedmineTelegramConnectionsController < ApplicationController
  unloadable


  def create
    @user = User.find(params[:user_id])
    @user.mail == params[:user_email]

    @telegram_account = Redmine2FA::TelegramAccount.find_by(telegram_id: params[:telegram_id])

    # binding.pry

    if @user.mail == params[:user_email] and params[:token] == 'token'

      @user.telegram_account = @telegram_account
      @user.save
    end


  end
end
