module Redmine2FA
  class CodeSender::SMSSender < CodeSender
    attr_reader :errors

    def initialize(user)
      @user      = user
      @errors    = []
    end

    def send_message
      phone   = @user.mobile_phone
      command = Redmine2FA::Configuration.sms_command
      command = command.sub('%{phone}', phone).sub('%{password}', code).sub('%{expired_at}', timestamp)
      system command
    end
  end
end
