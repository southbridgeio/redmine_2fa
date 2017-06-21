namespace :redmine_2fa do
  namespace :common do
    # bundle exec rake redmine_2fa:common:migrate
    task migrate: :environment do
      Redmine2FA::TelegramAccount.find_each do |telegram_account|
        TelegramCommon::Account.where(telegram_id: telegram_account.telegram_id)
          .first_or_create(telegram_account.slice(:user_id, :first_name, :last_name, :username, :active))
      end
    end
  end
end
