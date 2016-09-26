module Redmine2FA
  class AuthSource::GoogleAuth < AuthSource
    def auth_method_name
      'Google Auth'
    end
  end
end
