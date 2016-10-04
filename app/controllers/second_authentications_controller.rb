class SecondAuthenticationsController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required, only: [:update]
  before_filter :authorize, only: [:update]

  def update
    @user.update!(auth_source_id: params[:auth_source_id])
    Redmine2FA::OtpAuth.new.send_code(@user)
    render 'account/redmine_2fa'
  end

  def destroy
    User.current.reset_second_auth
    flash[:notice] = l(:notice_2fa_reset)
    redirect_to my_account_path
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
