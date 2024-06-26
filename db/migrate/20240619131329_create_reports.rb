class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.text :reason
      t.references :reportable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
