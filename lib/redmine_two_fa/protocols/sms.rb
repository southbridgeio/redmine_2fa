module RedmineTwoFa::Protocols
  class Sms < BaseProtocol
    TIMEOUT = 20

    def send_code(user)
      phone   = user.mobile_phone
      timestamp = Time.use_zone(user.time_zone) { 2.minutes.from_now.strftime('%H:%M:%S') }
      command = RedmineTwoFa::Configuration.sms_command
      command = command.sub('%{phone}', phone).sub('%{password}', user.otp_code).sub('%{expired_at}', timestamp)

      pid = Process.spawn(command)

      begin
        Timeout.timeout(TIMEOUT) { Process.wait(pid) }
      rescue Timeout::Error
        Process.kill('TERM', pid)
      end
    end

    def resendable?
      true
    end

    def initial_partial
      'account/init_2fa/sms'
    end
  end
end
