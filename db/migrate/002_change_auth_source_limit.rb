class ChangeAuthSourceLimit < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    change_column :auth_sources, :type, :string, limit: 40
  end

  def down
    change_column :auth_sources, :type, :string, limit: 30
  end
end
