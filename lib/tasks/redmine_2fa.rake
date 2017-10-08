namespace :redmine_2fa do
  namespace :common do
    # bundle exec rake redmine_2fa:common:migrate
    task migrate: :environment do
      Redmine2FA::TelegramAccount.find_each do |telegram_account|
        TelegramCommon::Account.where(telegram_id: telegram_account.telegram_id)
          .first_or_create(telegram_account.slice(:user_id, :first_name, :last_name, :username, :active))
      end
    end

    desc 'Migrate behavior 2fa'
    task migrate_auth_source: :environment do
      types = %w(Redmine2FA::AuthSource::Telegram Redmine2FA::AuthSource::SMS Redmine2FA::AuthSource::GoogleAuth)
      auth_sources = AuthSource.where(type: types)
      User.where(auth_source_id: auth_sources.pluck(:id)).each do |user|
        user.two_fa_id = user.auth_source_id
        user.auth_source_id = nil
        if user.save
          print '.'
        else
          puts "\nUser ##{user.id} save failed: #{user.errors.messages.to_json}"
        end
      end
      puts ''
    end
  end
end
