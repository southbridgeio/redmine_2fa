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
