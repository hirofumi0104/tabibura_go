class DropOldMapsAndPins < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :pins, :maps if foreign_key_exists?(:pins, :maps)
    drop_table :pins, if_exists: true
    drop_table :maps, if_exists: true
  end
end
