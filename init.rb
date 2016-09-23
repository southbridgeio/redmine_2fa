FileUtils.mkdir_p(Rails.root.join('log/redmine_2fa')) unless Dir.exist?(Rails.root.join('log/redmine_2fa'))

require 'redmine_2fa'

ActionDispatch::Callbacks.to_prepare do
  paths = '/app/models/redmine_2fa/*.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end

  paths = '/lib/redmine_2fa/{patches/*_patch,hooks/*_hook,*}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_2fa do
  name 'Redmine 2FA'
  version '0.2.0'
  url 'https://github.com/centosadmin/redmine_2fa'
  description 'Two-factor authorization for Redmine'
  author 'Centos-admin.ru'
  author_url 'https://centos-admin.ru'

  settings(default: { 'bot_token' => 'bot_token' },
           partial: 'settings/redmine_2fa')
end
