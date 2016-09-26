module Redmine2FA
  def self.table_name_prefix
    'redmine_2fa_'
  end

  module Configuration
    def self.configuration
      Redmine::Configuration['redmine_2fa']
    end

    def self.sms_command
      configuration && configuration['sms_command'] ? configuration['sms_command'] : 'echo %{phone} %{password}'
    end
  end
end
