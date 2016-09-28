class AddAuthSources < ActiveRecord::Migration
  def up
    Redmine2FA::AuthSource::Telegram.create name: 'Telegram', onthefly_register: false, tls: false
    Redmine2FA::AuthSource::GoogleAuth.create name: 'Google Auth', onthefly_register: false, tls: false

    if AuthSource.where(name: 'SMS').present?
      AuthSource.where(name: 'SMS').update_all(type: 'Redmine2FA::AuthSource::SMS')
    else
      Redmine2FA::AuthSource::SMS.create name: 'SMS', onthefly_register: false, tls: false
    end

  end

  def down
    Redmine2FA::AuthSource::Telegram.destroy_all
    Redmine2FA::AuthSource::SMS.destroy_all
    Redmine2FA::AuthSource::GoogleAuth.destroy_all
  end
end
