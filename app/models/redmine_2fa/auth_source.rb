class Redmine2FA::AuthSource < AuthSource
  def authenticate(login, password)
    # Just default redmine password check
    user = User.where(login: login).first
    if user && User.hash_password("#{user.salt}#{User.hash_password(password)}") == user.hashed_password
      user
    end
  end

  def self.allow_password_changes?
    true
  end

  def self.all
    AuthSource.where(type: %w(Redmine2FA::AuthSource::Telegram Redmine2FA::AuthSource::SMS Redmine2FA::AuthSource::GoogleAuth))
  end
end
