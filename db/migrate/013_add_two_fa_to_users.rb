class AddTwoFaToUsers < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :users, :two_fa, :string, index: true
  end
end
