class CreateMapPins < ActiveRecord::Migration[8.0]
  def change
    create_table :map_pins do |t|
      t.references :post, null: false, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.string :label

      t.timestamps
    end
  end
end
