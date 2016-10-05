module Redmine2FA
  class CodeSender

    attr_reader :user, :errors, :sender

    def initialize(user)
      @user   = user
      @errors = []
      @sender = define_sender
    end

    def send_code
      sender.send_message
      errors.concat(sender.errors) if sender.errors.present?
    end

    private

    def define_sender
      case user&.auth_source&.auth_method_name
        when 'Telegram'
          CodeSender::TelegramSender.new(user)
        when 'SMS'
          CodeSender::SMSSender.new(user)
        else
          CodeSender::NullSender.new
      end
    end

    private

    def code
      user.otp_code
    end

    def timestamp
      2.minutes.from_now.strftime('%H:%M:%S')
    end

  end

end
