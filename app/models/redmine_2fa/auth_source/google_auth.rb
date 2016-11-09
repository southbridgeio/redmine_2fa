class Redmine2FA::AuthSource::GoogleAuth < Redmine2FA::AuthSource
  def auth_method_name
    'Google Auth'
  end

  def protocol
    'google_auth'
  end
end
