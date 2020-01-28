module RedmineTwoFa::Protocols
  class None < BaseProtocol
    def bypass?
      true
    end

    def initial_partial
      'account/init_2fa/none'
    end
  end
end
