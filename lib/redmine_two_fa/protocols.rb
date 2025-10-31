module RedmineTwoFa
  module Protocols
    REGISTRY = {
      sms: Sms.new,
      google_auth: GoogleAuth.new,
      telegram: RedmineTwoFa::Protocols::Telegram.new,
      none: None.new
    }.freeze

    def self.[](key)
      return if key.nil?

      REGISTRY[key.to_sym]
    end

    def self.keys
      REGISTRY.keys.map(&:to_s)
    end
  end
end
