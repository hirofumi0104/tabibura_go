class ChangeAddressToLabelInMaps < ActiveRecord::Migration[8.0]
  def change
    remove_column :maps, :address, :string
    add_column :maps, :label, :string
  end
end
