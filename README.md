[![Build Status](https://travis-ci.org/southbridgeio/redmine_2fa.svg?branch=master)](https://travis-ci.org/southbridgeio/redmine_2fa) [![Code Climate](https://codeclimate.com/github/southbridgeio/redmine_2fa/badges/gpa.svg)](https://codeclimate.com/github/southbridgeio/redmine_2fa)
[![Rate at redmine.org](http://img.shields.io/badge/rate%20at-redmine.org-blue.svg?style=flat)](http://www.redmine.org/plugins/redmine_2fa)

[Русская версия](https://github.com/southbridgeio/redmine_2fa/blob/master/README.ru.md)

# Redmine 2FA

Two-factor authorization plugin for Redmine.

Supports:

- Telegram
- SMS
- Google Auth

## Requirements

- [redmine_bots](https://github.com/southbridgeio/redmine_bots)
- HTTPS host - Telegram Bot Webhook needs to POST on HTTPS hosts.
- Ruby 2.3+

### Upgrade to 1.6.0+

From 1.6.0 redmine_2fa depends on [redmine_bots](https://github.com/southbridgeio/redmine_bots) instead of redmine_telegram_common.
Please, install it and follow migration instructions from README of redmine_bots.

### Upgrade from 1.3.4 to 1.4.0+

From 1.4.0 redmine_2fa (as well as other Southbridge telegram plugins) is using bot from redmine_telegram_common.
In order to perform migration to single bot you should run `bundle exec rake telegram_common:migrate_to_single_bot`.
Bot token will be taken from one of installed Southbridge plugins in the following priority:

* redmine_chat_telegram
* redmine_intouch
* redmine_2fa

Also you should re-initialize bot on redmine_telegram_common settings page.

### Upgrade form 1.1.3 to 1.2.0+

Since version 1.2.0 this plugin uses [redmine_telegram_common](https://github.com/southbridgeio/redmine_telegram_common) plugin.

Before upgrade install [this](https://github.com/southbridgeio/redmine_telegram_common) plugin.

Then upgrade and run `bundle exec rake redmine_2fa:common:migrate` for migrate data to new table.

Since 2.0 version, model `Redmine2FA::TelegramAccount` will be removed, also table `redmine_2fa_telegram_accounts` will be removed.

### Important!!!

A bot can operate either via the web-hook, or through periodic polling.

This plugin uses web-hook mechanism, so be sure to use the HTTPS protocol.

If one and the same bot uses different mechanisms in different plug-ins, priority is given to web-hook.

Instructions for creating a bot: <https://core.telegram.org/bots#3-how-do-i-create-a-bot>

#### Hints for bot commands

Use command `/setcommands` with [@BotFather](https://telegram.me/botfather). Send this list for setup hints:

```
start - Start work with bot
connect - Connect Redmine and Telegram account
help - Help about commands
```

## Installation

After cloning repo to `plugins` directory run these commands

```
bundle
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

# Telegram authentication

## Plugin settings

After installation you need to setup plugin settings:

- enter bot token
- save settings
- initialize bot

During initialization bot id and username will be saved and web-hook, which will process commands sent by the bot, will be setup.

## User init

On first login the user will be asked to choose an authentication method.

After selecting Telegram the user needs to add a bot with `/start` command.

After that the bot prompts to enter the command `/connect account@redmine.com`.

After the command, the user will receive an email with a link.

Following the link will connect the user's accounts and he will be able to receive one-time passwords from the bot.

# SMS authentication

## Common info

If the user selects SMS he needs to enter the phone number to which he will receive SMS to confirm the number.

## Configuration

The responsibility of sending sms-message falls to external command, because there are many sms-gateways with different API. It can be any shell script or command like `curl`, e.g. for [smscentre.com](http://smscentre.com/reg/?AD306203):

```
/usr/bin/curl --silent --show-error "https://smsc.ru/sys/send.php?charset=utf-8&login=smsclogin&psw=smscpassword&phones=%{phone}&mes=southbridge.io code: %{password} Expired at: %{expired_at}"
```

`%{phone}`, `%{password}` and `%{expired_at}` are placeholders. They will be replaced with actual data during runtime.

- phone - phone number in format 7894561230 (digits only, starts with country code)
- password - one-time password
- expired_at - password expiration time (2 minutes after message sent)

Set SMS command in `config/configuration.yml` in `production` section:

```yaml
# specific configuration options for production environment
# that overrides the default ones
production:
  redmine_2fa:
    sms_command: '/usr/bin/curl --silent --show-error "https://smsc.ru/sys/send.php?charset=utf-8&login=smsclogin&psw=smscpassword&phones=%{phone}&mes=southbridge.io code: %{password} Expired at: %{expired_at}"'
```

This is worked example. If you want to use [this service](http://smscentre.com/reg/?AD306203), replace `smsclogin` and `smscpassword` with actual data after registration.

## Migration from redmine_sms_auth plugin

- update redmine_sms_auth to latest version from (repo)[<https://github.com/southbridgeio/redmine_sms_auth>]
- update redmine_2fa to latest version
- run `bundle install`
- run `bundle exec rake redmine:plugins:migrate`
- run `bundle exec rake redmine:plugins:migrate VERSION=0 NAME=redmine_sms_auth`
- remove plugin folder `redmine_sms_auth`
- update sms command settings in `configuration.yml`

  - before

    ```yaml
    production:
      sms_auth:
        command: 'echo %{phone} %{password}'
        password_length: 5
    ```

  - after

    ```yaml
    production:
      redmine_2fa:
        sms_command: 'echo %{phone} %{password}'
    ```

- restart Redmine

`password_length` parameter is no longer used, since Google Auth uses fixed-length code - 6 digits.

The plugin redmine_sms_auth added the "mobile phone" field to users.

Migration by this instruction will save phone data and it will be available in the plugin redmine_2fa.

# Google Authenticator

If the user chooses Google Auth he needs to scan QR-code in [Google Authenticator](https://support.google.com/accounts/answer/1066447).

# Authentication reset

The user can reset two-factor authentication on the "My Account" page.

# Ignore 2FA

The administrator can specify "Ignore 2FA" on the user setting page.

If plugin settings option "Require 2FA for each user" is switched off, user can select "Do not use" on first login.

# Author

Developed by [Southbridge](https://southbridge.io)
