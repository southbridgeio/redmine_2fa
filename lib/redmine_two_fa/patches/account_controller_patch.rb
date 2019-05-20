require_dependency 'account_controller'
require_dependency 'auth_source'

module RedmineTwoFa::Patches
  module AccountControllerPatch
  end
end

AccountController.send(:prepend, RedmineTwoFa::Patches::AccountControllerPatch::SecondAuthenticationStep)
AccountController.send(:prepend, RedmineTwoFa::Patches::AccountControllerPatch::SecondAuthenticationInit)
AccountController.send(:prepend, RedmineTwoFa::Patches::AccountControllerPatch::SecondAuthenticationPrepare)

AccountController.send(:include, RedmineTwoFa::Patches::AccountControllerPatch::ConfirmMethods)
