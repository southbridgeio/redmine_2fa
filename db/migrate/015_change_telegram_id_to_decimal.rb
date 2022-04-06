class ChangeTelegramIdToDecimal < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    change_column :redmine_2fa_telegram_accounts, :telegram_id, :decimal
    change_column :redmine_2fa_telegram_connections, :telegram_id, :decimal
    change_column :users, :two_fa_id, :decimal
  end
end
