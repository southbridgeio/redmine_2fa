class AddMobilePhoneToUsers < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    add_column :users, :mobile_phone, :string unless column_exists? :users, :mobile_phone
  end

  def down
    remove_column :users, :mobile_phone unless Redmine::Plugin.installed?(:redmine_sms_auth)
  end
end
