class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.boolean :read

      t.timestamps
    end
  end
end
