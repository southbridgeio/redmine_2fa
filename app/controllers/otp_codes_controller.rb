class OtpCodesController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required
  before_filter :set_user_from_session

  def create # resend
    send_code(@user)
    respond_to do |format|
      format.js
    end
  end

  private

  def set_user_from_session
    if session[:otp_user_id]
      @user = User.find(session[:otp_user_id])
    else
      deny_access
    end
  end

  def send_code(user)
    Redmine2FA::CodeSender.new(user).send_code
  end
end
