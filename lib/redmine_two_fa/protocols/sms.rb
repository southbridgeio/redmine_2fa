module RedmineTwoFa::Protocols
  class Sms < BaseProtocol
    def send_code(user)
      phone   = user.mobile_phone
      command = RedmineTwoFa::Configuration.sms_command
      command = command.sub('%{phone}', phone).sub('%{password}', user.otp_code).sub('%{expired_at}', timestamp)

      Process.spawn(command)
    end
  end
end
