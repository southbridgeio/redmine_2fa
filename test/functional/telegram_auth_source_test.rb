require File.expand_path('../../test_helper', __FILE__)

class TelegramAuthSourceTest < ActionController::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user = User.find(2) #jsmith
    @user.two_fa = 'telegram'
    @user.save
  end

  context 'telegram_id' do
    setup do
      @telegram_id = 999_999_999_999
    end

    should 'user can handle two_fa_id above integer range' do
      @user.two_fa_id = @telegram_id
      @user.save
    end

    should 'telegram_connection can handle telegram_id above integer range' do
      RedmineTwoFa::TelegramConnection.create!(telegram_id: @telegram_id, user_id: @user.id)
    end

    should 'telegram_accounts can handle telegram_id above integer range' do
      RedmineTwoFa::TelegramAccount.create!(telegram_id: @telegram_id, user_id: @user.id)
    end
  end
end
