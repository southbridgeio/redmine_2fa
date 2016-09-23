class Redmine2FA::AuthSourceSms < AuthSource
  def authenticate(login, password)
    # Just default redmine password check
    user = User.where(login: login).first
    if user && User.hash_password("#{user.salt}#{User.hash_password(password)}") == user.hashed_password
      user
    end
  end

  def auth_method_name
    'SMS'
  end

  def self.allow_password_changes?
    true
  end
end
