class Add2faToUsers < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :users, :two_fa_id, :integer, index: true
  end
end
