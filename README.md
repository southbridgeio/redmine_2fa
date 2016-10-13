[![Build Status](https://travis-ci.org/centosadmin/redmine_2fa.svg?branch=master)](https://travis-ci.org/centosadmin/redmine_2fa)
[![Code Climate](https://codeclimate.com/github/centosadmin/redmine_2fa/badges/gpa.svg)](https://codeclimate.com/github/centosadmin/redmine_2fa)

# Redmine 2FA

Two-factor authorization plugin for Redmine.

Supports:
* Telegram
* SMS
* Google Auth

Developed by [Centos-admin.ru](https://centos-admin.ru/)

## Requirements

This plugin works only on HTTPS host, because of Telegram Bot Webhook needs to POST on HTTPS hosts.

Ruby 2.3+

### Important!!!

Bot for this plugin must be unique. 
Otherwise, there may be conflicts if the same bot used in another plug-in with polling mode updates.

Bot can be operated either via the web-hook, or through periodic polling.

This plugin uses web-hook mechanism, so be sure to use the HTTPS protocol.

If a different plug-ins the same bot uses different mechanisms priority given to web-hook.

Instructions for creating a bot: https://core.telegram.org/bots#3-how-do-i-create-a-bot

## Instalation

After clone repo to `plugins` directory run this commands

```
bundle
bin/rake redmine:plugins:migrate
```

# Telegram authentication

## Plugin settings

After install you need to setup plugin settings: 
* enter bot token
* save settings
* initialize bot

Initialization will be save bot id and username and setup web-hook, which will process the command sent by the bot.

## User init

On first login user will be asked to choose an authentication method.
 
After selecting Telegram users need to add the bot with `/start` command.

After this it prompts you to enter the command `/connect account@redmine.com`.

After the command, the user will receive an email with a link.
Following by link will connect the user's account and he will be able to receive one-time passwords from bot/

# SMS authentication

## Common info

If user select SMS he need to enter the phone number to which it will receive SMS and confirm it.

## Configuration

Because there are many sms-gateways with different API, the responsibility on sending sms-message falls to external command. It can be any shell script or command like `curl`, e.g.

```
curl "http://my-sms-gateway.net?phone=%{phone}&message=Code: %{password} Expired at: %{expired_at}"
```
`%{phone}`, `%{password}` and `%{expired_at}` are placeholders. They will be replaced with actual data during runtime. 

* phone - phone number in format 7894561230 (digits only, starts with country code)
* password - one-time password
* expired_at - password expiration time (2 minutes after message sent)

Set SMS command in `config/configuration.yml` in `production` section:
```yaml
# specific configuration options for production environment
# that overrides the default ones
production:
  redmine_2fa:
    sms_command: 'curl "http://my-sms-gateway.net?phone=%{phone}&message=Code: %{password} Expired at: %{expired_at}"'
```

## Migration from redmine_sms_auth plugin

* update redmine_sms_auth to latest version from (repo)[https://github.com/centosadmin/redmine_sms_auth] 
* update redmine_2fa to latest version
* run `bundle install`
* run `bundle exec rake redmine:plugins:migrate`
* run `bundle exec rake redmine:plugins:migrate VERSION=0 NAME=redmine_sms_auth`
* remove plugin folder `redmine_sms_auth`
* update sms command settings in `configuration.yml`
  * before
    ```yaml
    production:
      sms_auth:
        command: 'echo %{phone} %{password}'
        password_length: 5
    ```
  * after
    ```yaml
    production:
      redmine_2fa:
        sms_command: 'echo %{phone} %{password}'
    ```

* restart Redmine

`password_length` parameter is no longer used, since Google Auth uses fixed-length code - 6 digits.

The plugin redmine_sms_auth added to the "mobile phone" field to users.

Migration by this instruction will save phone data and it will be available in the plugin redmine_2fa.

# Google Authenticator

If user choose Google Auth he need to scan QR-code in [Google 
Authenticator](https://support.google.com/accounts/answer/1066447).

# Authentication reset

User can reset two-factor authentication on the "My Account" page.

# Ignore 2FA

Administrator can specify "Ignore 2FA" on the user setting page.

If plugin settings option "Require 2FA for each user" is switched off, 
user can select "Do not use" on first login.

# Author

Developed by [Centos-admin.ru](https://centos-admin.ru/).

