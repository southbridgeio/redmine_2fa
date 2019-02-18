class AddApiAllowedToUsers < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :users, :api_allowed, :boolean, default: false, null: false
  end
end
