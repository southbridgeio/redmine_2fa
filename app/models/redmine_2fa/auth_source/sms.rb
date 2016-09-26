module Redmine2FA
  class AuthSource::SMS < AuthSource
    def auth_method_name
      'SMS'
    end
  end
end
