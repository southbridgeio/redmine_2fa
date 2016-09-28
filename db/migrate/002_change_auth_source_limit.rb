class ChangeAuthSourceLimit < ActiveRecord::Migration
  def up
    change_column :auth_sources, :type, :string, limit: 40
  end

  def down
    change_column :auth_sources, :type, :string, limit: 30
  end
end
