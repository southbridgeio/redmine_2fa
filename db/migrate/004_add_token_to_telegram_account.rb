class AddTokenToTelegramAccount < ActiveRecord::Migration
  def up
    add_column :redmine_2fa_telegram_accounts, :token, :string
    Redmine2FA::TelegramAccount.find_each { |telegram_account| telegram_account.update_attribute(:token, ROTP::Base32.random_base32) }
  end

  def down
    remove_column :redmine_2fa_telegram_accounts, :token
  end
end
