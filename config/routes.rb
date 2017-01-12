scope 'redmine_2fa' do
  # Plugin settings

  post 'bot/init' => 'otp_bot#create', as: 'otp_bot_init'
  delete 'bot/reset' => 'otp_bot#destroy', as: 'otp_bot_reset'

  # 2FA init
  put 'mobile_phone/update', to: 'user_mobile_phone#update', as: 'user_mobile_phone_update'
  post 'mobile_phone/confirm', to: 'user_mobile_phone#confirm', as: 'user_mobile_phone_confirm'

  post 'confirm', to: 'account#confirm_2fa', as: 'confirm_2fa'

  # 2FA management

  delete 'users/:id/reset', to: 'second_authentications#destroy', as: 'second_authentication_reset'

  # 2FA step

  post 'otp_code/resend', to: 'otp_codes#create', as: 'resend_otp'
  post 'otp_code/confirm', to: 'account#confirm_otp', as: 'confirm_otp'

  # Telegram bot webhook

  post 'bot/:token/update' => 'otp_bot_webhook#update'
end
