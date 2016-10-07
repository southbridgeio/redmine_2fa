module Redmine2FA
  module Hooks
    class IgnoreTfaUserFormHook < Redmine::Hook::ViewListener
      render_on :view_users_form, partial: 'redmine_2fa/hooks/ignore_2fa_form_field'
    end
  end
end
