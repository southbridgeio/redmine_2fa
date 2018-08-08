class TransferTelegramConnections < ActiveRecord::Migration
  def up
    User.where(two_fa_id: Redmine2FA::AuthSource::Telegram.first.id).each do |user|
      next unless user.telegram_account
      Redmine2FA::TelegramConnection.create!(user_id: user.id, telegram_id: user.telegram_account.telegram_id)
    end
  end
end