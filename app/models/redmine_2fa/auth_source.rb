class Redmine2FA::AuthSource < AuthSource
  def authenticate(login, password)
    # Just default redmine password check
    user = User.where(login: login).first
    user if user && User.hash_password("#{user.salt}#{User.hash_password(password)}") == user.hashed_password
  end

  def self.allow_password_changes?
    true
  end
end
