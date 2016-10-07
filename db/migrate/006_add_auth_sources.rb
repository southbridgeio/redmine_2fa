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
    auth_sources = AuthSource.where(type: %w(Redmine2FA::AuthSource::Telegram Redmine2FA::AuthSource::SMS Redmine2FA::AuthSource::GoogleAuth))
    User.where(auth_source_id: auth_sources.pluck(:id)).update_all(auth_source_id: nil)
    auth_sources.destroy_all
  end
end
