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

    def self.password_length
      configuration && configuration['password_length'] && configuration['password_length'].to_i > 0 ?
          configuration['password_length'].to_i : 4
    end
  end
end
