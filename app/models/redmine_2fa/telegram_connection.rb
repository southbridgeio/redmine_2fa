module Redmine2FA
  class TelegramConnection < ActiveRecord::Base
    belongs_to :user
  end
end
