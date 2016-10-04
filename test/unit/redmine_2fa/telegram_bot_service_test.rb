require File.expand_path('../../../test_helper', __FILE__)

class Redmine2FA::TelegramBotServiceTest < ActiveSupport::TestCase
  fixtures :users, :email_addresses, :roles


  setup do
    Redmine2FA.stubs(:bot_token)
    Telegrammer::Bot.any_instance.stubs(:get_me)

    @user = User.find(2)

    @telegram_message = ActionController::Parameters.new(
        from: { id:         123,
                username:   @user.login,
                first_name: @user.firstname,
                last_name:  @user.lastname },
        chat: { id: 123 },
        text: '/start'
    )

    @bot_service = Redmine2FA::Telegram::BotService.new(@telegram_message)
  end

  context '/start' do
    def test_start_create_telegram_account
      Telegrammer::Bot.any_instance.expects(:send_message)

      assert_difference('Redmine2FA::TelegramAccount.count') do
        @bot_service.start
      end

      telegram_account = Redmine2FA::TelegramAccount.last
      assert_equal 123, telegram_account.telegram_id
      assert_equal @user.login, telegram_account.username
      assert_equal @user.firstname, telegram_account.first_name
      assert_equal @user.lastname, telegram_account.last_name
      assert telegram_account.active
    end

    def test_start_update_telegram_account
      Telegrammer::Bot.any_instance.expects(:send_message)

      telegram_account = Redmine2FA::TelegramAccount.create(telegram_id: 123, username: 'test', first_name: 'f', last_name: 'l')

      assert_no_difference('Redmine2FA::TelegramAccount.count') do
        @bot_service.start
      end

      telegram_account.reload

      assert_equal @user.login, telegram_account.username
      assert_equal @user.firstname, telegram_account.first_name
      assert_equal @user.lastname, telegram_account.last_name
    end

    def test_start_activate_telegram_account
      Telegrammer::Bot.any_instance.expects(:send_message)
      actual = Redmine2FA::TelegramAccount.create(telegram_id: 123, active: false)

      assert_no_difference('Redmine2FA::TelegramAccount.count') do
        @bot_service.start
      end

      actual.reload

      assert actual.active
    end

    def test_start_send_message_for_connected_user
      Redmine2FA::Telegram::BotService.any_instance.
          expects(:send_message).
          with(123, I18n.t('redmine_2fa.redmine_telegram_connections.create.success'))

      Redmine2FA::TelegramAccount.create(telegram_id: 123, user_id: @user.id)
      @bot_service.start
    end

    def test_start_send_instruction_message
      Redmine2FA::Telegram::BotService.any_instance.
          expects(:send_message).
          with(123, I18n.t('redmine_2fa.otp_bot.start.instruction_html'))

      Redmine2FA::TelegramAccount.create(telegram_id: 123)
      @bot_service.start
    end
  end

  # /start



  # /connect e@mail.com

  def test_user_not_found_message
    skip 'need to write test'
  end

  def test_block_telegram_account_after_three_wrong_trials
    skip 'need to write test'
  end

  def test_already_connected
    skip 'need to write test'
  end

  def test_send_connect_instructions
    skip 'need to write test'
  end


end

