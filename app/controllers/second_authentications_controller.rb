class SecondAuthenticationsController < ApplicationController
  unloadable

  def destroy
    User.find(params[:id]).reset_second_auth
    flash[:notice] = l(:notice_2fa_reset)
    redirect_to(:back)
  end
end
