post :telegram_confirm, to: 'account#telegram_confirm', as: :telegram_confirm
get :telegram_resend, to: 'account#telegram_resend', as: :telegram_resend

get 'redmine_2fa/telegram_connect' => 'redmine_telegram_connections#create', as: 'redmine_2fa_telegram_connect'
