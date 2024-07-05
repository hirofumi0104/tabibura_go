class AddAdminIdToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :admin_id, :integer
    add_index :notifications, :admin_id
  end
end
