require File.expand_path('../../../test_helper', __FILE__)

class TelegramCommon::BotTest < ActiveSupport::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    Redmine2FA.stubs(:bot_token)
    Telegram::Bot::Api.any_instance.stubs(:get_me)
  end

  context '/start' do
    setup do
      @telegram_message = ActionController::Parameters.new(
        from: {
          id: 123,
          username: 'dhh',
          first_name: 'David',
          last_name: 'Haselman'
        },
        chat: {
          id: 123,
          type: 'private'
        },
        text: '/start'
      )

      @bot_service = TelegramCommon::Bot.new(Redmine2FA.bot_token, @telegram_message)
    end

    context 'with user' do
      setup do
        TelegramCommon::Bot.any_instance
          .expects(:send_message)
          .with(I18n.t('telegram_common.bot.start.hello'))

        @user = User.find(2)
        @telegram_account = TelegramCommon::Account.create(telegram_id: 123, user_id: @user.id)

        @bot_service.call
      end

      should 'set telegram auth source' do
        @user.reload
        assert_equal auth_sources(:telegram), @user.auth_source
      end
    end
  end
end
