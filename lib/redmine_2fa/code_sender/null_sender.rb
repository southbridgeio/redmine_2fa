module Redmine2FA
  class CodeSender::NullSender
    attr_reader :errors

    def initialize
      @errors = []
    end

    def send_message
    end
  end
end
