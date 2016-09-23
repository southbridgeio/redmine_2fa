module Redmine2FA
  module Hooks
    class UserFormHook < Redmine::Hook::ViewListener
      render_on :view_users_form, partial: 'redmine_2fa/hooks/mobile_phone_form_field'
      render_on :view_my_account, partial: 'redmine_2fa/hooks/mobile_phone_form_field'
    end
  end
end
