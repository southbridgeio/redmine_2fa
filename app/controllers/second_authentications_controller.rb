class SecondAuthenticationsController < ApplicationController
  unloadable

  def destroy
    User.current.reset_second_auth
    flash[:notice] = l(:notice_2fa_reset)
    redirect_to my_account_path
  end

end
