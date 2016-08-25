class CreateTelegramAccounts < ActiveRecord::Migration
  def change
    create_table :redmine_telegram_auth_telegram_accounts do |t|
      t.integer :telegram_id
      t.string :username
      t.string :first_name
      t.string :last_name
      t.boolean :active, default: true, null: false
      t.belongs_to :user, index: true, foreign_key: true
    end
    add_index :redmine_telegram_auth_telegram_accounts, :telegram_id
  end
end
