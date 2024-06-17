class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :itinerary
      t.text :caption
      t.string :main_image
      t.integer :status, default: 0, null: false
      
      t.timestamps
    end
  end
end
