module Redmine2FA
  class AuthSource::Telegram < AuthSource
    def auth_method_name
      'Telegram'
    end
  end
end
