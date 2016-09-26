class AddSmsAuth < ActiveRecord::Migration
  def up
    Redmine2FA::AuthSource::SMS.create name: 'SMS', onthefly_register: false, tls: false
  end

  def down
    Redmine2FA::AuthSource::SMS.destroy_all
  end
end
