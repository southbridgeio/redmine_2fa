module Redmine2FA
  module AuthSource
    class SMS < ::AuthSource; end
    class Telegram < ::AuthSource; end
    class GoogleAuth < ::AuthSource; end
  end
end

class TransferTwoFa < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    telegram_id = Redmine2FA::AuthSource::Telegram.last.id
    sms_id = Redmine2FA::AuthSource::SMS.last.id
    google_id = Redmine2FA::AuthSource::GoogleAuth.last.id

    puts 'Transferring user two_fa...'

    User.where(two_fa_id: [telegram_id, sms_id, google_id]).each do |user|
      user.update_column(:two_fa, 'telegram') if user.two_fa_id == telegram_id
      user.update_column(:two_fa, 'sms') if user.two_fa_id == sms_id
      user.update_column(:two_fa, 'google_auth') if user.two_fa_id == google_id
    end

    puts 'Destroying legacy auth sources...'

    Redmine2FA::AuthSource::Telegram.delete_all
    Redmine2FA::AuthSource::SMS.delete_all
    Redmine2FA::AuthSource::GoogleAuth.delete_all
  end
end
