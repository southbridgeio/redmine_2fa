class UserMobilePhoneController < ApplicationController
  unloadable

  skip_before_action :check_if_login_required

  before_action :set_user_from_session

  def update
    @user.mobile_phone = params[:user][:mobile_phone]
    send_confirmation_code(@user) if @user.save
  end

  def confirm
    @user.confirm_mobile_phone(params[:code]) if params[:code]
  end

  private

  def send_confirmation_code(user)
    protocol = RedmineTwoFa::Protocols[:sms]
    protocol.send_code(user)
  end

  def set_user_from_session
    if session[:otp_user_id]
      @user = User.find(session[:otp_user_id])
    else
      deny_access
    end
  end

  private

  def logger
    @logger ||= RedmineTwoFa.logger
  end
end
