class Building < ApplicationRecord
  extend Enumerize

  TYPE_APARTMENT = 'アパート'.freeze
  TYPE_HOUSE = '一戸建て'.freeze
  TYPE_MANSION = 'マンション'.freeze

  enumerize :structure_type, in: [TYPE_APARTMENT, TYPE_HOUSE, TYPE_MANSION], predicates: true

  validates :unique_assigned_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :structure_type, presence: true

  validate :room_number_presence_based_on_structure_type

  private

  def room_number_presence_based_on_structure_type
    if structure_type != TYPE_HOUSE && room_number.blank?
      errors.add(:room_number, 'must be present for アパート and マンション')
    end
  end
end
