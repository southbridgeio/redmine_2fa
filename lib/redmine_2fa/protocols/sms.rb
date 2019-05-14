class Sms < BaseProtocol
  def send_code(user)
    phone   = user.mobile_phone
    command = Redmine2FA::Configuration.sms_command
    command = command.sub('%{phone}', phone).sub('%{password}', user.otp_code).sub('%{expired_at}', timestamp)

    pid = Process.spawn(command)

    begin
      Timeout.timeout(20) { Process.wait(pid) }
    rescue Timeout::Error
      Process.kill('TERM', pid)
      errors << 'SMS service unavailable: timeout error'
    end
  end

  def id
    'sms'
  end
end
