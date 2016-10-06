require_dependency 'account_controller'

AccountController.send(:prepend, Redmine2FA::Patches::AccountControllerPatch::SecondAuthenticationStep)
AccountController.send(:prepend, Redmine2FA::Patches::AccountControllerPatch::SecondAuthenticationInit)
AccountController.send(:prepend, Redmine2FA::Patches::AccountControllerPatch::SecondAuthenticationPrepare)

AccountController.send(:include, Redmine2FA::Patches::AccountControllerPatch::ConfirmMethods)
