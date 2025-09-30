class DropAdminsTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :admins
  end

  def down
    create_table :admins do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.timestamps
    end
    add_index :admins, :email, unique: true
    add_index :admins, :reset_password_token, unique: true
  end
end
