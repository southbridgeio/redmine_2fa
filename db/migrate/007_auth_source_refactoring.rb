class AuthSourceRefactoring < ActiveRecord::Migration
  def up
    change_column :auth_sources, :type, :string, limit: 40
    AuthSource.where(name: 'SMS').update_all(type: 'Redmine2FA::AuthSource::SMS')
    AuthSource.where(name: 'Telegram').update_all(type: 'Redmine2FA::AuthSource::Telegram')
  end

  def down
    change_column :auth_sources, :type, :string, limit: 30
    AuthSource.where(name: 'SMS').update_all(type: 'Redmine2FA::AuthSourceSms')
    AuthSource.where(name: 'Telegram').update_all(type: 'Redmine2FA::AuthSourceTelegram')
  end
end
