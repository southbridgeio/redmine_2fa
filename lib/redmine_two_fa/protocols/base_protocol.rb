module RedmineTwoFa::Protocols
  class BaseProtocol
    def second_step_partial
      'account/otp'
    end

    def initial_partial
      raise NotImplementedError
    end

    def send_code(_user); end

    def bypass?
      false
    end

    def resendable?
      false
    end
  end
end
