require File.expand_path('../../../../test_helper', __FILE__)

class Redmine2FA::CodeSender::TelegramSenderTest < ActiveSupport::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources
  setup do
    User.any_instance.stubs(:otp_code).returns('123456')

    @user                 = User.find(2)
    @telegram_auth_source = auth_sources(:telegram)
    @user.auth_source     = @telegram_auth_source
  end

  # context 'initialize with user' do
  #
  #   should 'store user' do
  #     @sender = Redmine2FA::CodeSender.new(@user)
  #     assert_equal @user, @sender.user
  #   end
  #   should 'store code' do
  #     @sender = Redmine2FA::CodeSender.new(@user)
  #     assert_equal '123456', @sender.code
  #   end
  #
  #   should 'store timestamp' do
  #     Timecop.freeze(Time.parse('12:00:00 UTC')) do
  #       @sender = Redmine2FA::CodeSender.new(@user)
  #       assert_equal '12:02:00', @sender.timestamp
  #     end
  #   end
  #
  #
  # end
end
