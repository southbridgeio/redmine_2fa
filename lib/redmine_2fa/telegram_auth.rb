module Redmine2FA
  module TelegramAuth


    def self.send_otp_code(user)
      puts "AUTH CODE: #{user.otp_code}"
    end

  end
end
