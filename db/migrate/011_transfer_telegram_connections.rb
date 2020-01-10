module Redmine2FA
  module AuthSource
    class SMS < ::AuthSource; end
    class Telegram < ::AuthSource; end
    class GoogleAuth < ::AuthSource; end
  end
end

class TransferTelegramConnections < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  class TelegramAccount < ActiveRecord::Base
    belongs_to :user
  end

  class User < Principal
    has_one :telegram_account
  end

  def up
    return unless ActiveRecord::Base.connection.table_exists? 'telegram_accounts'

    User.where(two_fa_id: Redmine2FA::AuthSource::Telegram.first&.id).each do |user|
      next unless user.telegram_account
      RedmineTwoFa::TelegramConnection.create!(user_id: user.id, telegram_id: user.telegram_account.telegram_id)
    end
  end
end