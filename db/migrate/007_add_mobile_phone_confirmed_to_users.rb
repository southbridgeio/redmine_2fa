class AddMobilePhoneConfirmedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_phone_confirmed, :boolean, default: false, null: false
  end
end
