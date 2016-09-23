# Redmine SMS Auth


Plugin adds SMS-authentication to [Redmine](http://www.redmine.org/). Plugin compatible with Redmine 2.0.x and higher.

Please help us make this plugin better telling us of any [issues](https://github.com/centosadmin/redmine_sms_auth/issues) you'll face using it. We are ready to answer all your questions regarding this plugin.

## Some notes

When you use SMS-authentication user should pass two steps: standard password checking and sms-password confirmation.

If user's mobile phone is blank, plugin authenticates him with password checking only.

When you create new user you should set user's password with 'Internal' authentication mode, save, change authentication mode to 'SMS'. Otherwise user will be created without password. You can use same way for user's password changing. User can change his password by himself too.

Because there are many sms-gateways with different API, the responsibility on sending sms-message falls to external command. It can be any shell script or command like `curl`, e.g.
```
curl http://my-sms-gateway.net?phone=%{phone}&message=%{password}
```
`%{phone}` and `%{password}` are placeholders. They will be replaced with actual data during runtime. Default command is `echo %{phone} %{password}`.

Default password length is 4.

## WARNING

All **rake** commands must be run with correct **RAILS_ENV** variable, e.g.
```
RAILS_ENV=production rake redmine:plugins:migrate
```

## Installation

1. Stop redmine

2. Clone repository to your redmine/plugins directory
```
git clone git://github.com/centosadmin/redmine_sms_auth.git
```

3. Run migration
```
rake redmine:plugins:migrate
```

4. Add command for sms sending (and optionally password length) to configuration.yml
```yaml
    production:
      sms_auth:
        command: 'echo %{phone} %{password}'
        password_length: 5
```

5. Run redmine

6. Set 'Authentication mode' to 'SMS' for each user (Administration - Users)
7. (Optionally) Set mobile phone number for each user. Also user can set number for himself.

## Uninstall

1. Set 'Authentication mode' to 'Internal' for each user (Administration - Users)

2. Stop redmine.

3. Remove 'sms_auth' section from configuration.yml

4. Rollback migration
```
rake redmine:plugins:migrate VERSION=0 NAME=redmine_sms_auth
```

5. Remove plugin directory from your redmine/plugins directory

## Sponsors

Work on this plugin was fully funded by [Centos-admin.ru](http://centos-admin.ru)
