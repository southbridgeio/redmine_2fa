module RedmineTwoFa::Patches
  module ApplicationControllerPatch
    def find_current_user
      user = super
      return user unless api_request? || api_key_from_request.present?
      return user unless Setting.rest_api_enabled? && Setting.plugin_redmine_2fa['restrict_api_access'] && accept_api_auth?
      user&.api_allowed? ? user : nil
    end
  end
end

Rails.configuration.to_prepare do
  ApplicationController.prepend(RedmineTwoFa::Patches::ApplicationControllerPatch)
end
