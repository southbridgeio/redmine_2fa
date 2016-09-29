require_dependency 'account_controller'

AccountController.send(:prepend, Redmine2FA::Patches::AccountControllerPatch::SecondAuthenticationStep) # 2
AccountController.send(:prepend, Redmine2FA::Patches::AccountControllerPatch::SecondAuthenticationInit) # 1
