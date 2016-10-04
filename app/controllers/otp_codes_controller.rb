class OtpCodesController < ApplicationController
  unloadable

  before_filter :authorize

  def create # resend
    send_otp_code(@user)
    respond_to do |format|
      format.html do
        flash[:notice] = t('redmine_2fa.notice.auth_code.resent_again')
        render 'redmine_2fa/redmine_2fa'
      end
      format.js
    end
  end

  def update # confirm
    if @user.authenticate_otp(params[:otp_code], drift: 120)
      reset_otp_session
      successful_authentication(@user)
    else
      increment_failed_attempts
      if session[:otp_failed_attempts] >= 3
        send_otp_code(@user)
        flash[:error] = t('redmine_2fa.notice.auth_code.limit_exceeded_failed_attempts')
      else
        @hide_countdown = true
        flash[:error]   = t('redmine_2fa.notice.auth_code.invalid')
      end
      render 'redmine_2fa/redmine_2fa'
    end
  end

  private

  def authorize
    if session[:otp_user_id]
      @user = User.find(session[:otp_user_id])
    else
      deny_access
    end
  end
end
