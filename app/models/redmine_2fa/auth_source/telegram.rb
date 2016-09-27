class Redmine2FA::AuthSource::Telegram < Redmine2FA::AuthSource
  def auth_method_name
    'Telegram'
  end
end
