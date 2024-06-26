class AddLocationToPosts < ActiveRecord::Migration[6.1]
  # postにカラム追加
  def change
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float
  end
end
