module RedmineTwoFa
  module Protocols
    extend Dry::Container::Mixin

    class << self
      def resolve(*)
        super
      rescue Dry::Container::Error
        nil
      end
    end

    register :sms, Sms.new
    register :google_auth, GoogleAuth.new
    register :telegram, RedmineTwoFa::Protocols::Telegram.new
    register :none, None.new
  end
end
