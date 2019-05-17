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
    phone   = user.mobile_phone.gsub(/[^-+0-9]+/, '') # Additional phone sanitizing
    command = RedmineTwoFa::Configuration.sms_command
    command = command.sub('%{phone}', phone).sub('%{password}', user.otp_code)
    system command
  rescue => e
    logger.error e.message
    e.backtrace.each { |line| logger.error line }

    render_error message: t('redmine_2fa.second_authentications.sms.error'), status: 503
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
