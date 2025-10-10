class BuildingCsvFile < ApplicationRecord
  has_one_attached :file
  # For local testing
  # COLUMN_UNIQUE_ID = "unique_id".freeze
  # COLUMN_NAME = "name".freeze
  # COLUMN_ADDRESS = "address".freeze
  # COLUMN_STRUCTURE_TYPE = "type".freeze
  # COLUMN_ROOM_NUMBER = "room_number".freeze
  # COLUMN_SIZE = "size".freeze

  # ユニークID,物件名,住所,部屋番号,賃料,広さ,建物の種類
  COLUMN_UNIQUE_ID = "ユニークID".freeze
  COLUMN_NAME = "物件名".freeze
  COLUMN_ADDRESS = "住所".freeze
  COLUMN_STRUCTURE_TYPE = "建物の種類".freeze
  COLUMN_ROOM_NUMBER = "部屋番号".freeze
  COLUMN_RENT_AMOUNT = "賃料".freeze
  COLUMN_SIZE = "広さ".freeze
end
