class CreateTelegramConnections < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :redmine_2fa_telegram_connections do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :telegram_id
    end
    add_index :redmine_2fa_telegram_connections, :telegram_id
  end
end