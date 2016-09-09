module Redmine2FA
  module TelegramAuth


    def self.random_telegram_auth_code
      Random.srand.to_s[0, 4]
    end

    def self.send_telegram_auth_code(telegram_account, auth_code)
      puts "AUTH CODE: #{auth_code}"
    end

  end
end
