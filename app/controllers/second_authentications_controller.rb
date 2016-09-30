class SecondAuthenticationsController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required

  def update
    if session[:otp_user_id]
      puts session[:otp_user_id].inspect
      @user = User.find(session[:otp_user_id])
      @user.update!(auth_source_id: params[:auth_source_id])
      Redmine2FA::OtpAuth.new.send_otp_code(@user)
      render 'account/redmine_2fa'
    else
      deny_access
    end
  end

  def destroy
    User.current.reset_second_auth
    flash[:notice] = l(:notice_google_auth_reseted)
    redirect_to my_account_path
  end
end
