class CreateBuildingCsvFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :building_csv_files do |t|
      t.timestamps
    end
  end
end
