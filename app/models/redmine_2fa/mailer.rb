class Redmine2FA::Mailer < ActionMailer::Base
  layout 'mailer'
  helper :application
  helper :issues
  helper :custom_fields

  include Redmine::I18n

  default from: "#{Setting.app_title} <#{Setting.mail_from}>"

  def self.default_url_options
    Mailer.default_url_options
  end

  def telegram_connect(user, telegram_account)
    Intouch.set_locale
    @user = user
    @telegram_account = telegram_account

    mail to: @user.mail, subject: I18n.t('redmine_2fa.mailer.telegram_connect.subject'),
         template_path: 'redmine_2fa/mailer'
  end
end
