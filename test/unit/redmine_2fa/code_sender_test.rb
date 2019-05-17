require File.expand_path('../../../test_helper', __FILE__)

class RedmineTwoFa::CodeSenderTest < ActiveSupport::TestCase
  fixtures :users, :email_addresses, :roles, :auth_sources

  setup do
    @user = User.find(2)
  end

  context 'initialize with user' do
    should 'store user' do
      @sender = RedmineTwoFa::CodeSender.new(@user)
      assert_equal @user, @sender.user
    end

    context 'define sender' do
      should 'be SMSSender' do
        @user.two_fa = auth_sources(:sms)
        @sender           = RedmineTwoFa::CodeSender.new(@user)
        assert @sender.sender.is_a?(RedmineTwoFa::CodeSender::SMSSender)
      end

      should 'be Null sender for google auth' do
        @user.two_fa = auth_sources(:google_auth)

        @sender = RedmineTwoFa::CodeSender.new(@user)
        assert @sender.sender.is_a?(RedmineTwoFa::CodeSender::NullSender)
      end

      should 'be Null sender by default' do
        @user.two_fa = nil

        @sender = RedmineTwoFa::CodeSender.new(@user)
        assert @sender.sender.is_a?(RedmineTwoFa::CodeSender::NullSender)
      end
    end
  end

  context 'send code' do
    should 'call send_message for sender' do
      sender_sender = mock
      sender_sender.expects(:send_message)
      sender_sender.stubs(:errors)
      RedmineTwoFa::CodeSender.any_instance.expects(:sender).at_least_once.returns(sender_sender)
      RedmineTwoFa::CodeSender.new(@user).send_code
    end

    should 'get errors from sender' do
      sender_sender = mock
      sender_sender.stubs(:send_message)
      sender_sender.expects(:errors).at_least_once.returns(['some errors'])
      RedmineTwoFa::CodeSender.any_instance.stubs(:sender).returns(sender_sender)
      sender = RedmineTwoFa::CodeSender.new(@user)
      sender.send_code
      assert_equal ['some errors'], sender.errors
    end
  end
end
