class Add2faToUsers < ActiveRecord::Migration
  def change
    add_column :users, :two_fa_id, :integer, index: true
  end
end
