class RenameAdminIdToFromAdminInNotifications < ActiveRecord::Migration[8.0]
  def change
    remove_column :notifications, :admin_id, :integer
    add_column :notifications, :sent_by_admin, :boolean, default: false
  end
end
