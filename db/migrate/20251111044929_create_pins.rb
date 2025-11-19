class CreatePins < ActiveRecord::Migration[8.0]
  def change
    create_table :pins do |t|
      t.references :map, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.string :label

      t.timestamps
    end
  end
end
