require 'csv'

class BuildingCsvImportJob < ApplicationJob
  queue_as :default

  def perform(building_csv_file_id)
    # TODO Update building_csv_file to track status of update, if it's been run, etc
    # TODO Destroy model/file if memory is an issue
    building_csv_file = BuildingCsvFile.find(building_csv_file_id)

    building_csv_file.file.open do |file|
      CSV.foreach(file.path, headers: true) do |row|
        begin
          building = Building.find_or_create_by(unique_assigned_id: row[BuildingCsvFile::COLUMN_UNIQUE_ID])
          building.update!(
            name: row[BuildingCsvFile::COLUMN_NAME],
            address: row[BuildingCsvFile::COLUMN_ADDRESS],
            structure_type: row[BuildingCsvFile::COLUMN_STRUCTURE_TYPE],
            # TODO What do if ROOM_NUMBER is present even though it's a house?
            room_number: row[BuildingCsvFile::COLUMN_ROOM_NUMBER],
            size: row[BuildingCsvFile::COLUMN_SIZE]
          )
        rescue => e
          # TODO Collect errors and submit to Error reporting OR stop using Job and expose all errors to user after redirect
          Rails.logger.error "Failed to process row #{row}: #{e.message}"
          next
        end
      end
    end
  end
end
