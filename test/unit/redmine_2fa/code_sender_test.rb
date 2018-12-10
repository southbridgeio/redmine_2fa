require File.expand_path('../../../test_helper', __FILE__)

class Redmine2FA::CodeSenderTest < ActiveSupport::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user = User.find(2)
  end

  describe 'initialize with user' do
    it 'store user' do
      @sender = Redmine2FA::CodeSender.new(@user)
      assert_equal @user, @sender.user
    end

    describe 'define sender' do
      it 'be SMSSender' do
        @user.two_fa = auth_sources(:sms)
        @sender           = Redmine2FA::CodeSender.new(@user)
        assert @sender.sender.is_a?(Redmine2FA::CodeSender::SMSSender)
      end

      it 'be Null sender for google auth' do
        @user.two_fa = auth_sources(:google_auth)

        @sender = Redmine2FA::CodeSender.new(@user)
        assert @sender.sender.is_a?(Redmine2FA::CodeSender::NullSender)
      end

      it 'be Null sender by default' do
        @user.two_fa = nil

        @sender = Redmine2FA::CodeSender.new(@user)
        assert @sender.sender.is_a?(Redmine2FA::CodeSender::NullSender)
      end
    end
  end

  describe 'send code' do
    it 'call send_message for sender' do
      sender_sender = mock
      sender_sender.expects(:send_message)
      sender_sender.stubs(:errors)
      Redmine2FA::CodeSender.any_instance.expects(:sender).at_least_once.returns(sender_sender)
      Redmine2FA::CodeSender.new(@user).send_code
    end

    it 'get errors from sender' do
      sender_sender = mock
      sender_sender.stubs(:send_message)
      sender_sender.expects(:errors).at_least_once.returns(['some errors'])
      Redmine2FA::CodeSender.any_instance.stubs(:sender).returns(sender_sender)
      sender = Redmine2FA::CodeSender.new(@user)
      sender.send_code
      assert_equal ['some errors'], sender.errors
    end
  end
end
