class UserMobilePhoneController < ApplicationController
  unloadable

  before_filter :require_login

  def update
    @user = User.current
    @user.mobile_phone = params[:user][:mobile_phone] if params[:user]
    @user.save
  end

  def confirm
    @user = User.current
    @user.confirm_mobile_phone(params[:code]) if params[:code]
  end
end
