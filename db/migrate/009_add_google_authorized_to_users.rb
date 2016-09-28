class AddGoogleAuthorizedToUsers < ActiveRecord::Migration
  def up
    add_column :users, :google_authenticated, :boolean, default: false, null: false
  end

  def down
    remove_column :users, :google_authenticated
  end
end
