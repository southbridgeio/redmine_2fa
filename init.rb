# This patch need for fix requires_redmine_plugin :redmine_telegram_common
# http://www.redmine.org/issues/6324
require 'redmine_pluginloader/patches/defer_plugin_dependency_check_patch'

FileUtils.mkdir_p(Rails.root.join('log/redmine_2fa')) unless Dir.exist?(Rails.root.join('log/redmine_2fa'))

Redmine::Plugin.register :redmine_2fa do
  name 'Redmine 2FA'
  version '1.2.1'
  url 'https://github.com/centosadmin/redmine_2fa'
  description 'Two-factor authorization for Redmine'
  author 'Centos-admin.ru'
  author_url 'https://centos-admin.ru'

  requires_redmine version_or_higher: '3.0'

  begin
    requires_redmine_plugin :redmine_telegram_common, version_or_higher: '0.0.1'
  rescue Redmine::PluginNotFound => e
    raise <<~TEXT
      \n=============== PLUGIN REQUIRED ===============
      Please install redmine_telegram_common plugin. https://github.com/centosadmin/redmine_telegram_common
      Upgrade form 1.1.3 to 1.2.0+ notes: https://git.io/vXqk3
      ===============================================
    TEXT
  end

  settings(default: { 'bot_token' => '',
                      'required' => false },
           partial: 'settings/redmine_2fa')
end

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_2fa'

  %w( /app/models/redmine_2fa/*.rb
      /app/models/redmine_2fa/auth_source/*.rb
      /lib/redmine_2fa/patches/account_controller_patch/*.rb
      /lib/redmine_2fa/*.rb
      /lib/redmine_2fa/code_sender/*.rb
      /lib/redmine_2fa/{patches/*_patch,hooks/*_hook,*}.rb).each do |paths|
    Dir.glob(File.dirname(__FILE__) + paths).each do |file|
      require_dependency file
    end
  end
end
