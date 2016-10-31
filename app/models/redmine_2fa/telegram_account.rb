# DEPRECATION: This model will be removed since 2.0 version

class Redmine2FA::TelegramAccount < ActiveRecord::Base
  unloadable

  belongs_to :user
  attr_accessible :user_id, :first_name, :last_name, :username, :active, :telegram_id

  before_save :set_token

  def name
    if username.present?
      "#{first_name} #{last_name} @#{username}"
    else
      "#{first_name} #{last_name}"
    end
  end

  def activate!
    update(active: true) unless active?
  end

  def deactivate!
    update(active: false) if active?
  end

  private

  def set_token
    self.token = ROTP::Base32.random_base32
  end
end
