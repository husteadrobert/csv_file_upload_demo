require "rails_helper"

RSpec.describe "Building functionality", type: :system do
  before do
    Building.create!(
      unique_assigned_id: "BLD001",
      name: "Test Apartment",
      address: "123 Test Street",
      structure_type: Building::TYPE_APARTMENT,
      room_number: "101",
      size: 45.5
    )

    Building.create!(
      unique_assigned_id: "BLD002",
      name: "Test House",
      address: "456 Test Avenue",
      structure_type: Building::TYPE_HOUSE,
      size: 120.0
    )
  end

  it "it displays all current buildings in the database on the index page" do
    visit buildings_path

    expect(page).to have_text("Buildings")
    
    within("tbody tr:first-child") do
      expect(page).to have_text("BLD001")
      expect(page).to have_text("Test Apartment")
      expect(page).to have_text("123 Test Street")
      expect(page).to have_text("アパート")
      expect(page).to have_text("101")
      expect(page).to have_text("45.5")
    end

    within("tbody tr:nth-child(2)") do
      expect(page).to have_text("BLD002")
      expect(page).to have_text("Test House")
      expect(page).to have_text("456 Test Avenue")
      expect(page).to have_text("一戸建て")
      expect(page).to have_text("120.0")
    end
  end

  context "when the CSV file is properly formed" do
    context "when the CSV file has proper data" do
      context "when the data shares an unique_ID" do
        it "updates those records" do
        end
      end
      context "when the data doesnt share an unique_ID" do
        it "creates new records" do
        end
      end
    end
    context "when the CSV file has bad data" do
      context "because it has extra info not needed" do
        it "creates new records" do
        end
      end
      context "becuase the columns have unexpected names" do
        it "fails and creates no records" do
        end
      end
      context "becuase it is missing important columns" do
        it "fails and creates no records" do
        end
      end
      context "because columsn lack data" do # for example, unique_id or structure_type
        context "because the room number is missing" do
          it "fails and creates no records" do
          end
        end
        context "because its missing some other important info" do
          it "fails and creates no records" do
          end
        end
      end
    end
  end

  context "when the CSV file is not a CSV file" do
    it "does not update any models" do
    end
  end
end
