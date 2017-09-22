namespace :redmine_2fa do
  namespace :common do
    # bundle exec rake redmine_2fa:common:migrate
    task migrate: :environment do
      Redmine2FA::TelegramAccount.find_each do |telegram_account|
        TelegramCommon::Account.where(telegram_id: telegram_account.telegram_id)
          .first_or_create(telegram_account.slice(:user_id, :first_name, :last_name, :username, :active))
      end
    end

    desc 'Remove old behavior 2fa'
    task remove_auth_source: :environment do
      auth_sources = AuthSource.where(type: %w(Redmine2FA::AuthSource::Telegram Redmine2FA::AuthSource::SMS Redmine2FA::AuthSource::GoogleAuth))
      User.where(auth_source_id: auth_sources.pluck(:id)).update_all(auth_source_id: nil)
    end
  end
end
