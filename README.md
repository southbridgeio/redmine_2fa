# Redmine 2FA

Two-factor authorization plugin for Redmine.

Supports:
* Telegram
* SMS
* Google Auth (coming soon)

Developed by [Centos-admin.ru](https://centos-admin.ru/)

## Requirements

This plugin works only on HTTPS host, because of Telegram Bot Webhook needs to POST on HTTPS hosts.

### Важно!!!

Бот для этого плагина должен быть уникальным. Иначе могут быть конфликты, если тот же бот используется в другом плагине в режиме опроса обновлений.

Бот может работать либо через web-hook либо через периодический опрос.

Если в разных плгинах один и тот же бот использует разные механизмы, приоретет отдаётся web-hook.

Инструкция по созданию бота: https://core.telegram.org/bots#3-how-do-i-create-a-bot

## Установка плагина

После добавления плагина в пупку `plugins` выполните следующие команды
```
bundle
bin/rake redmine:plugins:migrate
```

## Первый запуск

При первом запуске нужно: 
* ввести токен бота в настройках плагина
* сохранить настройки
* инициализировать бота по ссылке в настройках

Во время иницализации будут сохранены id и username бота и установлен web-hook, который будет обрабатывать команды направляемые боту.

## Настройки для пользователя

В режиме редактирования профиля пользователя нужно указать протокол авторизации Telegram.

При следующем входе пользователю будет предложено добавить себе бота, чтобы получать от него одноразовые пароли.

При добавлении бота, он предложит ввести команду `/connect e@mail.com` для получения ссылки на связывание аккаунтов Telegram и Redmine.

После выполнения команды пользователь получит письмо со ссылкой.
Переход по ссылке свяжет аккаунты пользователя и он сможет получать одноразовые пароли от бота

# Авторизация через SMS

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

## Миграция с плагина redmine_sms_auth

* обновите плагин redmine_sms_auth до последней версии
* обновите плагин redmine_2fa до последней версии
* выполните команду `bundle install`
* выполните команду `bundle exec rake redmine:plugins:migrate`
* выполните команду `bundle exec rake redmine:plugins:migrate VERSION=0 NAME=redmine_sms_auth`
* удалите каталог с плагином redmine_sms_auth
* обновите настройки в файле `configuration.yml`
  * было
    ```yaml
    production:
      sms_auth:
        command: 'echo %{phone} %{password}'
        password_length: 5
    ```
  * стало
    ```yaml
    production:
      redmine_2fa:
        sms_command: 'echo %{phone} %{password}'
        password_length: 5
    ```

* перезапустите Redmine

В плагине redmine_sms_auth к польвателям было добавлено поле "Мобильный телефон", значение которого используется для 
отправки СМС.

При миграции в соотвествии с этой инструкцией поле будет сохранено и данные с номерами телефонов будут доступны в 
плагине redmine_2fa.


# Автор плагина

Плагин разработан [Centos-admin.ru](http://centos-admin.ru/).

