module RedmineTwoFa
  class TelegramConnection < ActiveRecord::Base
    self.table_name = 'redmine_2fa_telegram_connections'

    belongs_to :user
  end
end
