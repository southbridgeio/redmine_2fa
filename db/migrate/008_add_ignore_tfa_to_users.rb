class AddIgnoreTfaToUsers < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :users, :ignore_2fa, :boolean, default: false, null: false
  end
end
