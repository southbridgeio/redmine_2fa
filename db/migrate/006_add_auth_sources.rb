class AddAuthSources < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    RedmineTwoFa::AuthSource::Telegram.create name: 'Telegram', onthefly_register: false, tls: false
    RedmineTwoFa::AuthSource::GoogleAuth.create name: 'Google Auth', onthefly_register: false, tls: false

    if AuthSource.where(name: 'SMS').present?
      AuthSource.where(name: 'SMS').update_all(type: 'RedmineTwoFa::AuthSource::SMS')
    else
      RedmineTwoFa::AuthSource::SMS.create name: 'SMS', onthefly_register: false, tls: false
    end
  end

  def down
    auth_sources = AuthSource.where(type: %w(RedmineTwoFa::AuthSource::Telegram RedmineTwoFa::AuthSource::SMS RedmineTwoFa::AuthSource::GoogleAuth))
    User.where(auth_source_id: auth_sources.pluck(:id)).update_all(auth_source_id: nil)
    auth_sources.destroy_all
  end
end
