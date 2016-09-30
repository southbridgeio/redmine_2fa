put 'redmine_2fa/confirm', to: 'second_authentications#update', as: 'second_authentication_confirm'
delete 'redmine_2fa/reset', to: 'second_authentications#destroy', as: 'second_authentication_reset'

post 'redmine_2fa/mobile_phone/update', to: 'user_mobile_phone#update', as: 'user_mobile_phone_update'
post 'redmine_2fa/mobile_phone/confirm', to: 'user_mobile_phone#confirm', as: 'user_mobile_phone_confirm'

post :google_authentications_reset, to: 'google_authentications#reset', as: :google_authentications_reset

post :otp_code_confirm, to: 'account#otp_code_confirm', as: :otp_code_confirm
get :otp_code_resend, to: 'account#otp_code_resend', as: :otp_code_resend

get 'redmine_2fa/telegram_connect' => 'redmine_telegram_connections#create', as: 'redmine_2fa_telegram_connect'

get 'redmine_2fa/bot/init' => 'otp_bot#init', as: 'redmine_2fa_bot_init'
get 'redmine_2fa/bot/deactivate' => 'otp_bot#deactivate', as: 'redmine_2fa_bot_deactivate'
post 'redmine_2fa/update' => 'otp_bot#update' # TODO: add bot token here
post 'redmine_2fa/bot/:token/update' => 'otp_bot#update' # TODO: add bot token here
