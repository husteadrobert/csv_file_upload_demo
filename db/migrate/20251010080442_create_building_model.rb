class CreateBuildingModel < ActiveRecord::Migration[7.1]
  def change
    create_table :buildings do |t|
      t.string :unique_assigned_id, null: false
      t.string :name, null: false
      t.string :address
      t.string :structure_type, null: false
      t.integer :room_number
      t.decimal :size, precision: 10, scale: 2

      t.timestamps
    end

    add_index :buildings, :unique_assigned_id, unique: true
  end
end
