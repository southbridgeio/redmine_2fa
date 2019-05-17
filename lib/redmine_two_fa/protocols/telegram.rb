module RedmineTwoFa::Protocols
  class Telegram < BaseProtocol
    def id
      'telegram'
    end

    def second_step_partial
      'account/telegram_login'
    end
  end
end
