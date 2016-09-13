# Redmine 2FA

Two-factor authorization plugin for Redmine.

Supports:
* Telegram
* SMS (coming soon)
* Google Auth (coming soon)

Developed by [Centos-admin.ru](https://centos-admin.ru/)

## Requirements

This plugin works only on HTTPS host, because of Telegram Bot Webhook needs to POST on HTTPS hosts.

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

Во время иницализации будут сохранены id и username бота и устновлен web-hook, который будет обрабатывать команды направляемые боту.

## Настройки для пользователя

В режиме редактирования профиля пользователя нужно указать протокол авторизации Telegram.

При следующем входе пользователю будет предложено добавить себе бота, чтобы получать от него одноразовые пароли.

При добавлении бота, он предложит ввести команду `/connect e@mail.com` для получения ссылки на связывание аккаунтов Telegram и Redmine.

После выполнения команды пользователь получит письмо со ссылкой.
Переход по ссылке свяжет аккаунты пользователя и он сможет получать одноразовые пароли от бота

# Автор плагина

Плагин разработан [Centos-admin.ru](http://centos-admin.ru/).

