class SecondAuthenticationsController < ApplicationController
  unloadable

  def destroy
    user = User.find(params[:id])
    if User.current.admin? || user == User.current
      user.reset_second_auth
      flash[:notice] = l(:notice_2fa_reset)
      redirect_to(:back)
    else
      render_403
    end
  end
end
