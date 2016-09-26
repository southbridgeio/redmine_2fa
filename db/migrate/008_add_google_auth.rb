class AddGoogleAuth < ActiveRecord::Migration
  def up
    Redmine2FA::AuthSource::GoogleAuth.create name: 'Google Auth', onthefly_register: false, tls: false
  end

  def down
    Redmine2FA::AuthSource::GoogleAuth.destroy_all
  end
end
