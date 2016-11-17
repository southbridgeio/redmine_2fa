[![Build Status](https://travis-ci.org/centosadmin/redmine_2fa.svg?branch=master)](https://travis-ci.org/centosadmin/redmine_2fa) [![Code Climate](https://codeclimate.com/github/centosadmin/redmine_2fa/badges/gpa.svg)](https://codeclimate.com/github/centosadmin/redmine_2fa)

[English version](https://github.com/centosadmin/redmine_2fa/blob/master/README.md)

# Redmine 2FA

Двухфакторная аутентификация для Redmine.

Поддерживает:

- Telegram
- SMS
- Google Authenticator

Плагин разработан [Centos-admin.ru](https://centos-admin.ru/)

[Описание плагина на habrahabr.ru](https://habrahabr.ru/company/centosadmin/blog/312656/)

## Требования

- [redmine_telegram_common](https://github.com/centosadmin/redmine_telegram_common)
- HTTPS - нужен для того, чтобы принимать сообщение от Telegram Bot API ([веб-хук](https://tlgrm.ru/docs/bots/api#setwebhook))
- Ruby 2.3+

### Обновление с 1.1.3 на 1.2.0+

Начиная с версии 1.2.0 это плагин использует [redmine_telegram_common](https://github
.com/centosadmin/redmine_telegram_common).

Перед обновлением установите [этот](https://github.com/centosadmin/redmine_telegram_common) плагин.

После обновления запустите `bundle exec rake redmine_2fa:common:migrate` для миграции пользоватльских данных в новую таблицу. В версии 2.0 модель `Redmine2FA::TelegramAccount` будет упразднена, в месте с ней будет удалена старая таблица `redmine_2fa_telegram_accounts`.

### Важно!!!

Бот для этого плагина должен быть уникальным. Иначе могут быть конфликты, если тот же бот используется в другом плагине в режиме опроса обновлений.

Бот может работать либо через web-hook либо через периодический опрос.

В этом плагине используется механизм web-hook, поэтому использование протокола HTTPS обязательно.

Если в разных плагинах один и тот же бот использует разные механизмы, приориетет отдаётся web-hook.

Инструкция по созданию бота: <https://tlgrm.ru/docs/bots#3-how-do-i-create-a-bot>

#### Подсказки для команд бота

Чтобы добавить подсказки команд для бота, используйте команду `/setcommands` в беседе с [@BotFather](https://telegram.me/botfather). Нужно написать боту список команд с 
описанием:

```
start - Начало работы с ботом
connect - Связывание аккаунтов Redmine и Telegram
help - Справка по командам
```

## Установка плагина

После добавления плагина в папку `plugins` выполните следующие команды

```
bundle
bin/rake redmine:plugins:migrate
```

# Аутентификация через Telegram

## Настройки плагина

После установки плагина в настройках плагина нужно:

- ввести токен бота
- сохранить настройки
- инициализировать бота

Во время инициализации будут сохранены id и username бота и установлен web-hook, который будет обрабатывать команды направляемые боту.

## Настройки для пользователя

При первом входе пользователю будет предложено выбрать способ аутентификации.

При выборе Telegram пользвателю нужно будет добавить себе бота, чтобы получать от него одноразовые пароли.

При добавлении бота, он предложит ввести команду `/connect e@mail.com`.

После выполнения команды пользователь получит письмо со ссылкой. Переход по ссылке свяжет аккаунты пользователя и он сможет получать одноразовые пароли от бота.

# Аутентификация через SMS

## Общая информация

При выборе SMS пользвателю нужно ввести номер телефона, на который он будет получать СМС и подтвердить его.

## Конфигурация

В связи с тем, что различные СМС-шлюзы используют различные API, в плагине испольуется отправка СМС через системную команду. Пример для сервиса [smsc.ru](http://www.smsc.ru/reg/?AD306203):

```
/usr/bin/curl --silent --show-error "https://smsc.ru/sys/send.php?charset=utf-8&login=smsclogin&psw=smscpassword&phones=%{phone}&mes=centos-admin.ru code: %{password} Expired at: %{expired_at}"
```

`%{phone}`, `%{password}` и `%{expired_at}` системные переменные, которые будут замещены соответствующими значениями.

- phone - номер телефона в формате 7894561230 (только цифры, начинается с кода страны)
- password - одноразовай пароль
- expired_at - время после которого пароль перестаёт быть действительным (2 минуты от момента отправки сообщения)

Команда для отправки СМС указывается в файле `config/configuration.yml` в секции `production`:

```yaml
# specific configuration options for production environment
# that overrides the default ones
production:
  redmine_2fa:
    sms_command: '/usr/bin/curl --silent --show-error "https://smsc.ru/sys/send.php?charset=utf-8&login=smsclogin&psw=smscpassword&phones=%{phone}&mes=centos-admin.ru code: %{password} Expired at: %{expired_at}"'
```

Это рабочий пример конфига. Если вы хотите польваться [сервисом](http://www.smsc.ru/reg/?AD306203), после регистрации замените `smsclogin` и `smscpassword` актуальными данными.

## Миграция с плагина redmine_sms_auth

- обновите плагин redmine_sms_auth до последней версии из [репозитория](https://github.com/centosadmin/redmine_sms_auth)
- обновите плагин redmine_2fa до последней версии
- выполните команду `bundle install`
- выполните команду `bundle exec rake redmine:plugins:migrate`
- выполните команду `bundle exec rake redmine:plugins:migrate VERSION=0 NAME=redmine_sms_auth`
- удалите каталог с плагином `redmine_sms_auth`
- обновите настройки в файле `configuration.yml`

  - было

    ```yaml
    production:
      sms_auth:
        command: 'echo %{phone} %{password}'
        password_length: 5
    ```

  - стало

    ```yaml
    production:
      redmine_2fa:
        sms_command: 'echo %{phone} %{password}'
    ```

- перезапустите Redmine

Параметр password_length больше не используется, так как в Google Auth используется фиксированная длинна кода - 6 цифр.

В плагине redmine_sms_auth к польвателям было добавлено поле "Мобильный телефон", значение которого используется для отправки СМС.

При миграции в соотвествии с этой инструкцией поле будет сохранено и данные с номерами телефонов будут доступны в плагине redmine_2fa.

# Google Authenticator

При выборе Google Auth пользвателю будет показан QR-код, который нужно сосканировать в приложении [Google Authenticator](https://support.google.com/accounts/answer/1066447).

# Сброс способа аутентификации

Пользователь может сбросить способ двухфакторной аутентификации на странице "Моя учётная запись".

# Игнорирование второго шага аутентификации

В настройках пользователя администратор может указать "Игнорировать 2FA".

Если в настройка плагина снята галка "Обязательно требовать выбрать один из способов аутентификации 2FA", то пользователь может выбрать "Не использовать" при первом входе в систему.

# Автор плагина

Плагин разработан [Centos-admin.ru](http://centos-admin.ru/).
