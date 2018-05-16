module Redmine2FA
  module JWT
    def self.strategies
      {
          telegram: TelegramStrategy.new
      }
    end
  end
end