require 'rails_helper'

RSpec.describe Building, type: :model do
  let(:valid_apartment_attributes) do
    {
      unique_assigned_id: 'APT001',
      name: 'Test Apartment',
      address: '123 Test Street',
      structure_type: Building::TYPE_APARTMENT,
      room_number: '101',
      size: 45.5,
      rent_amount: 150000
    }
  end

  let(:valid_house_attributes) do
    {
      unique_assigned_id: 'HOUSE001',
      name: 'Test House',
      address: '456 Test Avenue',
      structure_type: Building::TYPE_HOUSE,
      size: 120.0,
      rent_amount: 250000
    }
  end

  let(:valid_mansion_attributes) do
    {
      unique_assigned_id: 'MAN001',
      name: 'Test Mansion',
      address: '789 Test Boulevard',
      structure_type: Building::TYPE_MANSION,
      room_number: '302',
      size: 85.0,
      rent_amount: 300000
    }
  end

  describe 'validations' do
    describe 'unique_assigned_id' do
      it 'is required' do
        building = Building.new(valid_apartment_attributes.except(:unique_assigned_id))
        expect(building).not_to be_valid
        expect(building.errors[:unique_assigned_id]).to include("can't be blank")
      end

      it 'must be unique' do
        Building.create!(valid_apartment_attributes)
        duplicate_building = Building.new(valid_apartment_attributes)
        expect(duplicate_building).not_to be_valid
        expect(duplicate_building.errors[:unique_assigned_id]).to include('has already been taken')
      end

      it 'allows different unique_assigned_ids' do
        Building.create!(valid_apartment_attributes)
        different_building = Building.new(valid_house_attributes)
        expect(different_building).to be_valid
      end
    end

    describe 'name' do
      it 'is required' do
        building = Building.new(valid_apartment_attributes.except(:name))
        expect(building).not_to be_valid
        expect(building.errors[:name]).to include("can't be blank")
      end

      it 'allows any non-blank name' do
        building = Building.new(valid_apartment_attributes.merge(name: 'Any Building Name'))
        expect(building).to be_valid
      end
    end

    describe 'structure_type' do
      it 'is required' do
        building = Building.new(valid_apartment_attributes.except(:structure_type))
        expect(building).not_to be_valid
        expect(building.errors[:structure_type]).to include("can't be blank")
      end

      it 'accepts valid structure types' do
        [Building::TYPE_APARTMENT, Building::TYPE_HOUSE, Building::TYPE_MANSION].each do |type|
          building = Building.new(valid_apartment_attributes.merge(structure_type: type, room_number: '101'))
          expect(building).to be_valid
        end
      end

      it 'rejects invalid structure types' do
        building = Building.new(valid_apartment_attributes.merge(structure_type: 'Invalid Type'))
        expect(building).not_to be_valid
        expect(building.errors[:structure_type]).to include('is not included in the list')
      end
    end

    describe 'room_number validation based on structure_type' do
      context 'when structure_type is アパート' do
        it 'requires room_number' do
          building = Building.new(valid_apartment_attributes.except(:room_number))
          expect(building).not_to be_valid
          expect(building.errors[:room_number]).to include('must be present for アパート and マンション')
        end

        it 'rejects blank room_number' do
          building = Building.new(valid_apartment_attributes.merge(room_number: ''))
          expect(building).not_to be_valid
          expect(building.errors[:room_number]).to include('must be present for アパート and マンション')
        end

        it 'accepts non-blank room_number' do
          building = Building.new(valid_apartment_attributes.merge(room_number: '205'))
          expect(building).to be_valid
        end
      end

      context 'when structure_type is マンション' do
        it 'requires room_number' do
          building = Building.new(valid_mansion_attributes.except(:room_number))
          expect(building).not_to be_valid
          expect(building.errors[:room_number]).to include('must be present for アパート and マンション')
        end

        it 'rejects blank room_number' do
          building = Building.new(valid_mansion_attributes.merge(room_number: ''))
          expect(building).not_to be_valid
          expect(building.errors[:room_number]).to include('must be present for アパート and マンション')
        end

        it 'accepts non-blank room_number' do
          building = Building.new(valid_mansion_attributes.merge(room_number: '1205'))
          expect(building).to be_valid
        end
      end

      context 'when structure_type is 一戸建て' do
        it 'does not require room_number' do
          building = Building.new(valid_house_attributes.except(:room_number))
          expect(building).to be_valid
        end

        it 'allows blank room_number' do
          building = Building.new(valid_house_attributes.merge(room_number: ''))
          expect(building).to be_valid
        end

        it 'allows non-blank room_number' do
          building = Building.new(valid_house_attributes.merge(room_number: 'A1'))
          expect(building).to be_valid
        end
      end
    end
  end

  describe 'enumerize predicates' do
    let(:apartment) { Building.new(structure_type: Building::TYPE_APARTMENT) }
    let(:house) { Building.new(structure_type: Building::TYPE_HOUSE) }
    let(:mansion) { Building.new(structure_type: Building::TYPE_MANSION) }

    describe 'apartment predicates' do
      it 'returns true for apartment structure_type' do
        expect(apartment.structure_type_アパート?).to be true
        expect(apartment.structure_type_一戸建て?).to be false
        expect(apartment.structure_type_マンション?).to be false
      end
    end

    describe 'house predicates' do
      it 'returns true for house structure_type' do
        expect(house.structure_type_一戸建て?).to be true
        expect(house.structure_type_アパート?).to be false
        expect(house.structure_type_マンション?).to be false
      end
    end

    describe 'mansion predicates' do
      it 'returns true for mansion structure_type' do
        expect(mansion.structure_type_マンション?).to be true
        expect(mansion.structure_type_アパート?).to be false
        expect(mansion.structure_type_一戸建て?).to be false
      end
    end
  end

  describe 'database constraints' do
    it 'enforces unique index on unique_assigned_id at database level' do
      Building.create!(valid_apartment_attributes)
      expect {
        Building.create!(valid_apartment_attributes.merge(name: 'Different Name'))
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'model creation' do
    context 'with valid apartment attributes' do
      it 'creates successfully' do
        building = Building.create!(valid_apartment_attributes)
        expect(building.persisted?).to be true
        expect(building.unique_assigned_id).to eq('APT001')
        expect(building.name).to eq('Test Apartment')
        expect(building.structure_type).to eq(Building::TYPE_APARTMENT)
        expect(building.room_number).to eq('101')
        expect(building.size).to eq(45.5)
        expect(building.rent_amount).to eq(150000)
      end
    end

    context 'with valid house attributes' do
      it 'creates successfully' do
        building = Building.create!(valid_house_attributes)
        expect(building.persisted?).to be true
        expect(building.unique_assigned_id).to eq('HOUSE001')
        expect(building.name).to eq('Test House')
        expect(building.structure_type).to eq(Building::TYPE_HOUSE)
        expect(building.room_number).to be_nil
        expect(building.size).to eq(120.0)
        expect(building.rent_amount).to eq(250000)
      end
    end

    context 'with valid mansion attributes' do
      it 'creates successfully' do
        building = Building.create!(valid_mansion_attributes)
        expect(building.persisted?).to be true
        expect(building.unique_assigned_id).to eq('MAN001')
        expect(building.name).to eq('Test Mansion')
        expect(building.structure_type).to eq(Building::TYPE_MANSION)
        expect(building.room_number).to eq('302')
        expect(building.size).to eq(85.0)
        expect(building.rent_amount).to eq(300000)
      end
    end
  end

  describe 'model constants' do
    it 'defines the correct structure type constants' do
      expect(Building::TYPE_APARTMENT).to eq('アパート')
      expect(Building::TYPE_HOUSE).to eq('一戸建て')
      expect(Building::TYPE_MANSION).to eq('マンション')
    end
  end

  describe 'attribute types' do
    let(:building) { Building.create!(valid_apartment_attributes) }

    it 'stores string attributes correctly' do
      expect(building.unique_assigned_id).to be_a(String)
      expect(building.name).to be_a(String)
      expect(building.address).to be_a(String)
      expect(building.structure_type).to be_a(String)
      expect(building.room_number).to be_a(String)
    end

    it 'stores numeric attributes correctly' do
      expect(building.size).to be_a(BigDecimal)
      expect(building.rent_amount).to be_a(Integer)
    end

    it 'handles nil values for optional attributes' do
      building = Building.create!(valid_house_attributes.merge(
        address: nil,
        room_number: nil,
        size: nil,
        rent_amount: nil
      ))
      expect(building.address).to be_nil
      expect(building.room_number).to be_nil
      expect(building.size).to be_nil
      expect(building.rent_amount).to be_nil
    end
  end

  describe 'edge cases' do
    it 'handles large rent amounts' do
      building = Building.new(valid_apartment_attributes.merge(rent_amount: 9999999))
      expect(building).to be_valid
      building.save!
      expect(building.rent_amount).to eq(9999999)
    end

    it 'handles zero rent amount' do
      building = Building.new(valid_apartment_attributes.merge(rent_amount: 0))
      expect(building).to be_valid
      building.save!
      expect(building.rent_amount).to eq(0)
    end

    it 'handles negative rent amount' do
      building = Building.new(valid_apartment_attributes.merge(rent_amount: -100))
      expect(building).to be_valid
      building.save!
      expect(building.rent_amount).to eq(-100)
    end

    it 'handles very large size values' do
      building = Building.new(valid_apartment_attributes.merge(size: 99999.99))
      expect(building).to be_valid
      building.save!
      expect(building.size).to eq(BigDecimal('99999.99'))
    end

    it 'handles zero size' do
      building = Building.new(valid_apartment_attributes.merge(size: 0))
      expect(building).to be_valid
      building.save!
      expect(building.size).to eq(BigDecimal('0'))
    end

    it 'handles very long names' do
      long_name = 'A' * 1000
      building = Building.new(valid_apartment_attributes.merge(name: long_name))
      expect(building).to be_valid
      building.save!
      expect(building.name).to eq(long_name)
    end

    it 'handles very long addresses' do
      long_address = 'B' * 1000
      building = Building.new(valid_apartment_attributes.merge(address: long_address))
      expect(building).to be_valid
      building.save!
      expect(building.address).to eq(long_address)
    end

    it 'handles special characters in room numbers' do
      building = Building.new(valid_apartment_attributes.merge(room_number: 'A-101-B'))
      expect(building).to be_valid
      building.save!
      expect(building.room_number).to eq('A-101-B')
    end
  end

  describe 'update operations' do
    let!(:building) { Building.create!(valid_apartment_attributes) }

    it 'allows updating all mutable attributes' do
      building.update!(
        name: 'Updated Name',
        address: 'Updated Address',
        room_number: '999',
        size: 75.5,
        rent_amount: 200000
      )
      building.reload
      expect(building.name).to eq('Updated Name')
      expect(building.address).to eq('Updated Address')
      expect(building.room_number).to eq('999')
      expect(building.size).to eq(BigDecimal('75.5'))
      expect(building.rent_amount).to eq(200000)
    end

    it 'allows changing structure_type from apartment to house' do
      building.update!(structure_type: Building::TYPE_HOUSE, room_number: nil)
      building.reload
      expect(building.structure_type).to eq(Building::TYPE_HOUSE)
      expect(building.room_number).to be_nil
    end

    it 'prevents changing to apartment without room_number' do
      building.update!(structure_type: Building::TYPE_HOUSE, room_number: nil)
      building.structure_type = Building::TYPE_APARTMENT
      expect(building).not_to be_valid
      expect(building.errors[:room_number]).to include('must be present for アパート and マンション')
    end

    it 'allows updating unique_assigned_id to a new unique value' do
      building.update!(unique_assigned_id: 'UPDATED001')
      building.reload
      expect(building.unique_assigned_id).to eq('UPDATED001')
    end

    it 'prevents updating unique_assigned_id to an existing value' do
      Building.create!(valid_house_attributes)
      building.unique_assigned_id = 'HOUSE001'
      expect(building).not_to be_valid
      expect(building.errors[:unique_assigned_id]).to include('has already been taken')
    end
  end
end
