require_dependency Rails.root.join('plugins','redmine_bots', 'init')

FileUtils.mkdir_p(Rails.root.join('log/redmine_2fa')) unless Dir.exist?(Rails.root.join('log/redmine_2fa'))

require './plugins/redmine_2fa/lib/redmine_two_fa'
require 'telegram/bot'

register_after_redmine_initialize_proc =
  if Redmine::VERSION::MAJOR >= 5
    Rails.application.config.public_method(:after_initialize)
  else
    reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Reloader
    reloader.public_method(:to_prepare)
  end
register_after_redmine_initialize_proc.call do
  paths = '/lib/redmine_two_fa/{patches/*_patch,hooks/*_hook,*}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_2fa do
  name 'Redmine 2FA'
  version '1.7.6'
  url 'https://github.com/southbridgeio/redmine_2fa'
  description 'Two-factor authorization for Redmine'
  author 'Southbridge'
  author_url 'https://southbridge.io'

  requires_redmine version_or_higher: '3.0'

  requires_redmine_plugin :redmine_bots, '0.5.2'

  settings(default: { 'required' => false,
                      'active_protocols' => RedmineTwoFa::AVAILABLE_PROTOCOLS
  },
           partial: 'settings/redmine_2fa')
end
