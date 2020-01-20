module RedmineTwoFa::Protocols
  class GoogleAuth < BaseProtocol
    def generate_qr(user)
      qr_size ||= 10
      RQRCode::QRCode.new(user.provisioning_uri("#{user.login}", issuer: "#{Setting.host_name}"), size: qr_size, level: :h)
    rescue RQRCodeCore::QRCodeRunTimeError=> e
      retry unless (qr_size += 1) > 20
      raise e
    end

    def initial_partial
      'account/init_2fa/google_auth'
    end
  end
end
