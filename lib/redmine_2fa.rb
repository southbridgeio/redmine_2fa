module Redmine2FA
  def self.table_name_prefix
    'redmine_2fa_'
  end

  def self.set_locale
    I18n.locale = Setting['default_language']
  end

  def self.switched_on
    Setting.plugin_redmine_2fa['required']
  end

  def self.switched_off
    !switched_on
  end

  def self.bot_token
    Setting.plugin_redmine_2fa['bot_token']
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
