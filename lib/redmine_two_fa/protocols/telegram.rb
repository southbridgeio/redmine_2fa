module RedmineTwoFa::Protocols
  class Telegram < BaseProtocol
    def id
      'telegram'
    end

    def second_step_partial
      'account/telegram_login'
    end

    def initial_partial
      'account/init_2fa/telegram'
    end
  end
end
