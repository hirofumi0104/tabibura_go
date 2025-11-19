class RemoveCoordinatesFromMaps < ActiveRecord::Migration[8.0]
  def change
    remove_column :maps, :latitude, :float
    remove_column :maps, :longitude, :float
    remove_column :maps, :label, :string
  end
end
