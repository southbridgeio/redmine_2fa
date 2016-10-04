class OtpCodesController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required
  before_filter :authorize

  def create # resend
    send_code(@user)
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
        send_code(@user)
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

  def send_code(user)
    Redmine2FA::OtpAuth.new.send_code(user)
    session[:otp_failed_attempts] = 0
  end

  def reset_otp_session
    params[:back_url] = session[:otp_back_url]
    session.delete(:otp_user_id)
    session.delete(:otp_failed_attempts)
    session.delete(:otp_back_url)
  end

  def increment_failed_attempts
    session[:otp_failed_attempts] ||= 0
    session[:otp_failed_attempts] += 1
  end

  # Copied from account controller

  def successful_authentication(user)
    logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
    # Valid user
    self.logged_user = user
    # generate a key and set cookie if autologin
    if params[:autologin] && Setting.autologin?
      set_autologin_cookie(user)
    end
    call_hook(:controller_account_success_authentication_after, {:user => user })
    redirect_back_or_default my_page_path
  end

  def set_autologin_cookie(user)
    token = Token.create(:user => user, :action => 'autologin')
    secure = Redmine::Configuration['autologin_cookie_secure']
    if secure.nil?
      secure = request.ssl?
    end
    cookie_options = {
        :value => token.value,
        :expires => 1.year.from_now,
        :path => (Redmine::Configuration['autologin_cookie_path'] || RedmineApp::Application.config.relative_url_root || '/'),
        :secure => secure,
        :httponly => true
    }
    cookies[autologin_cookie_name] = cookie_options
  end
end
