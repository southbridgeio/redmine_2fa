class AddTelegramAuth < ActiveRecord::Migration
  def up
    Redmine2FA::AuthSource::Telegram.create name: 'Telegram', onthefly_register: false, tls: false
  end

  def down
    Redmine2FA::AuthSource::Telegram.destroy_all
  end
end
