class AddTelegramAuth < ActiveRecord::Migration
  def up
    Redmine2FA::AuthSourceTelegram.create name: 'Telegram', :onthefly_register => false, :tls => false
  end

  def down
    Redmine2FA::AuthSourceTelegram.destroy_all
  end
end
