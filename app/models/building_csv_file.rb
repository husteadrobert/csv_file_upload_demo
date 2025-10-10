class BuildingCsvFile < ApplicationRecord
  has_one_attached :file
  # ユニークID,物件名,住所,部屋番号,賃料,広さ,建物の種類
  COLUMN_UNIQUE_ID = "unique_id".freeze
  COLUMN_NAME = "name".freeze
  COLUMN_ADDRESS = "address".freeze
  COLUMN_STRUCTURE_TYPE = "type".freeze
  COLUMN_ROOM_NUMBER = "room_number".freeze
  COLUMN_SIZE = "size".freeze
end
