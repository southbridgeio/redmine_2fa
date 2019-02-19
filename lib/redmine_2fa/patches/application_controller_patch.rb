module TwoFaApplicationControllerPatch
  def find_current_user
    user = super
    return user unless Setting.rest_api_enabled? && Setting.plugin_redmine_2fa['restrict_api_access'] && accept_api_auth?
    user&.api_allowed? ? user : nil
  end
end

ApplicationController.prepend(TwoFaApplicationControllerPatch)
