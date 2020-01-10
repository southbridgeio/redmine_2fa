# 1.7.2

* Add API restriction option
* Refactor protocols
* Use rqrcode 1.0+

# 1.7.1

* Add deprecation warning
* Fix global timezone change

# 1.7.0

* Redmine 4 support

# 1.6.0

* Depend on redmine_bots instead of redmine_telegram_common
* Google auth confirmation on first page
* Telegram account connection/2fa connection segregation
* Don't send code to locked users

# 1.5.1

* Add redmine_telegram_common dependency to init.rb

# 1.5.0

* Use Telegram login
* Fix "Code sent" message
* Fix RQRCode::QRCodeRunTimeError

# 1.4.0

* Update telegram-bot-ruby
* Use bot from redmine_telegram_common
* Add link to bot in code instruction

# 1.3.4

* Add bot collision check

# 1.3.3

* Fix missing locale 2fa
* Fix "account not found" issue with /connect bug
* Add another auth sources support (like LDAP)
* Remove old reference to MultiJSON
* Remove Telegrammer dependency

# 1.3.2

* Add reset 2fa for admin.

# 1.3.1

* Add timeout handling for SMS command

# 1.3.0

* Add ability to select available protocols for 2FA - [Issue #3](https://github.com/centosadmin/redmine_2fa/issues/3)

# 1.2.6
* Add requirement notification to plugin settings page
# 1.2.5

* Remove dependency code

# 1.2.4

* remove defer plugin dependency check patch

# 1.2.3

* extract bot to `redmine_telegram_common`

# 1.2.2

* extract mailer to `redmine_telegram_common`

# 1.2.1

* add `requires_redmine_plugin :redmine_telegram_common`,
* add defer plugin dependency check patch for load `redmine_telegram_common` before `redmine_2fa` loaded. Extracted from [here](https://github.com/michaelkrupp-redmine/redmine_pluginloader). [Redmine issue](http://www.redmine.org/issues/6324#change-73605).

# 1.2.0

Migrate to [redmine_telegram_common](https://github.com/centosadmin/redmine_telegram_common) plugin.
* before upgrade please install [this](https://github.com/centosadmin/redmine_telegram_common) plugin.
* run `bundle exec rake redmine_2fa:common:migrate` after upgrade

# 1.1.3

Optimize Bot Webhook Controller

# 1.1.2
* Changelog init
