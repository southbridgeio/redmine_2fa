class AddIgnoreTfaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ignore_2fa, :boolean, default: false, null: false
  end
end
