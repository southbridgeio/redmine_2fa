module Redmine2FA
  module Hooks
    class ViewMyAccountContextualHook < Redmine::Hook::ViewListener
      render_on :view_my_account_contextual, partial: 'second_authentications/reset', user: @user
      render_on :view_users_form, partial: 'second_authentications/link_to_reset'
    end
  end
end
