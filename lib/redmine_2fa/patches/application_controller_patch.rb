module TwoFaApplicationControllerPatch
  def accept_api_auth?(*)
    super && (!Setting.plugin_redmine_2fa['restrict_api_access'] || User.current.api_allowed?)
  end
end

ApplicationController.prepend(TwoFaApplicationControllerPatch)
