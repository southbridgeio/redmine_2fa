class AddSmsAuth < ActiveRecord::Migration
  def up
    Redmine2FA::AuthSourceSms.create name: 'SMS', onthefly_register: false, tls: false
  end

  def down
    Redmine2FA::AuthSourceSms.destroy_all
  end
end
