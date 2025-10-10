require 'csv'

class BuildingCsvImportJob < ApplicationJob
  queue_as :default

  def perform(building_csv_file_id)
    building_csv_file = BuildingCsvFile.find(building_csv_file_id)

    building_csv_file.file.open do |file|
      CSV.foreach(file.path, headers: true) do |row|
        Building.create!(
          unique_assigned_id: row['unique_id'],
          name: row['name'],
          address: row['address'],
          structure_type: row['type'],
          room_number: row['room_number'],
          size: row['size']
        )
      end
    end
  end
end
