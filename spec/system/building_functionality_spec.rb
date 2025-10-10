require "rails_helper"
require "csv"

RSpec.describe "Building functionality", type: :system do
  include ActiveJob::TestHelper
  before do
    Building.create!(
      unique_assigned_id: "BLD001",
      name: "Test Apartment",
      address: "123 Test Street",
      rent_amount: 1234567,
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
    # TODO check for 100+ records being paginated
    visit buildings_path

    expect(page).to have_text("Buildings")

    within("tbody tr:first-child") do
      expect(page).to have_text("BLD001")
      expect(page).to have_text("Test Apartment")
      expect(page).to have_text("123 Test Street")
      expect(page).to have_text("アパート")
      expect(page).to have_text("101")
      expect(page).to have_text("1234567")
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
        before do
          @csv_file = Rails.root.join("spec", "fixtures", "files", "duplicate_ids.csv")

          CSV.open(@csv_file, "w") do |csv|
            csv << ["ユニークID", "物件名", "住所", "部屋番号", "賃料", "広さ", "建物の種類"]
            csv << ["UNQ001", "サンシャインマンション", "東京都渋谷区1-1", "101", "150000", "65.5", "マンション"]
            csv << ["UNQ002", "グリーンビル", "大阪府大阪市2-2", "202", "120000", "55.0", "アパート"]
            csv << ["UNQ003", "オーシャンビュー", "神奈川県横浜市3-3", "", "180000", "75.5", "一戸建て"]
            csv << ["UNQ002", "グリーンビル改", "大阪府大阪市2-3", "203", "125000", "58.0", "アパート"]
            csv << ["UNQ004", "マウンテンハウス", "長野県長野市4-4", "404", "95000", "48.5", "マンション"]
            csv << ["UNQ005", "リバーサイド", "京都府京都市5-5", "", "140000", "68.0", "一戸建て"]
            csv << ["UNQ002", "グリーンビル新館", "大阪府大阪市2-4", "204", "130000", "60.0", "マンション"]
          end
        end

        after do
          File.delete(@csv_file) if File.exist?(@csv_file)
        end

        it "updates records with the last occurrence of each unique_assigned_id" do
          visit buildings_path
          click_link "Upload CSV"
          attach_file "csv_file", @csv_file
          click_button "Upload"

          # Run all enqueued jobs
          perform_enqueued_jobs

          # Visit the buildings page again to see the updated data
          visit buildings_path

          # Check that UNQ002 has the data from its last occurrence in the CSV
          within("tbody") do
            unq002_row = find("tr", text: "UNQ002")
            within(unq002_row) do
              expect(page).to have_text("グリーンビル新館")
              expect(page).to have_text("大阪府大阪市2-4")
              expect(page).to have_text("204")
              expect(page).to have_text("130000")
              expect(page).to have_text("60.0")
              expect(page).to have_text("マンション")
            end
            # Verify other unique buildings appear on the page
            expect(page).to have_text("UNQ001")
            expect(page).to have_text("サンシャインマンション")
            expect(page).to have_text("UNQ003")
            expect(page).to have_text("オーシャンビュー")
            expect(page).to have_text("UNQ004")
            expect(page).to have_text("マウンテンハウス")
            expect(page).to have_text("UNQ005")
            expect(page).to have_text("リバーサイド")
          end
        end
      end
      context "when the data doesnt share an unique_ID" do
        before do
          @csv_file = Rails.root.join("spec", "fixtures", "files", "all_new_ids.csv")
          CSV.open(@csv_file, "w") do |csv|
            csv << ["ユニークID", "物件名", "住所", "部屋番号", "賃料", "広さ", "建物の種類"]
            csv << ["NEW001", "ニューシティタワー", "東京都港区1-1", "501", "250000", "85.5", "マンション"]
            csv << ["NEW002", "サンライズレジデンス", "神奈川県川崎市2-2", "302", "180000", "65.0", "アパート"]
            csv << ["NEW003", "グランドヴィラ", "千葉県千葉市3-3", "", "220000", "120.5", "一戸建て"]
            csv << ["NEW004", "パークサイドハイツ", "埼玉県さいたま市4-4", "204", "155000", "58.5", "マンション"]
            csv << ["NEW005", "オークウッドホーム", "東京都世田谷区5-5", "", "280000", "95.0", "一戸建て"]
            csv << ["NEW006", "レイクビューアパート", "茨城県つくば市6-6", "106", "98000", "42.0", "アパート"]
          end
        end

        after do
          File.delete(@csv_file) if File.exist?(@csv_file)
        end

        it "creates new records" do
          # Get initial count (should be 2 from the before block)
          initial_count = Building.count
          expect(initial_count).to eq(2)
          visit buildings_path
          click_link "Upload CSV"
          attach_file "csv_file", @csv_file
          click_button "Upload"

          # Run all enqueued jobs
          perform_enqueued_jobs

          # Visit the buildings page again to see the updated data
          visit buildings_path
          # Verify all new buildings appear on the page
          within("tbody") do
            # Check NEW001
            new001_row = find("tr", text: "NEW001")
            within(new001_row) do
              expect(page).to have_text("ニューシティタワー")
              expect(page).to have_text("東京都港区1-1")
              expect(page).to have_text("501")
              expect(page).to have_text("250000")
              expect(page).to have_text("85.5")
              expect(page).to have_text("マンション")
            end
            # Check NEW002
            new002_row = find("tr", text: "NEW002")
            within(new002_row) do
              expect(page).to have_text("サンライズレジデンス")
              expect(page).to have_text("神奈川県川崎市2-2")
              expect(page).to have_text("302")
              expect(page).to have_text("180000")
              expect(page).to have_text("65.0")
              expect(page).to have_text("アパート")
            end
            # Check NEW003
            new003_row = find("tr", text: "NEW003")
            within(new003_row) do
              expect(page).to have_text("グランドヴィラ")
              expect(page).to have_text("千葉県千葉市3-3")
              expect(page).to have_text("220000")
              expect(page).to have_text("120.5")
              expect(page).to have_text("一戸建て")
            end
            # Check NEW004
            new004_row = find("tr", text: "NEW004")
            within(new004_row) do
              expect(page).to have_text("パークサイドハイツ")
              expect(page).to have_text("埼玉県さいたま市4-4")
              expect(page).to have_text("204")
              expect(page).to have_text("155000")
              expect(page).to have_text("58.5")
              expect(page).to have_text("マンション")
            end
            # Check NEW005
            new005_row = find("tr", text: "NEW005")
            within(new005_row) do
              expect(page).to have_text("オークウッドホーム")
              expect(page).to have_text("東京都世田谷区5-5")
              expect(page).to have_text("280000")
              expect(page).to have_text("95.0")
              expect(page).to have_text("一戸建て")
            end
            # Check NEW006
            new006_row = find("tr", text: "NEW006")
            within(new006_row) do
              expect(page).to have_text("レイクビューアパート")
              expect(page).to have_text("茨城県つくば市6-6")
              expect(page).to have_text("106")
              expect(page).to have_text("98000")
              expect(page).to have_text("42.0")
              expect(page).to have_text("アパート")
            end
            # Also verify the original buildings are still there
            expect(page).to have_text("BLD001")
            expect(page).to have_text("Test Apartment")
            expect(page).to have_text("BLD002")
            expect(page).to have_text("Test House")
          end
          # Verify the total count (2 original + 6 new = 8)
          expect(Building.count).to eq(8)
        end
      end
    end
    context "when the CSV file has bad data" do
      context "because it has extra info not needed" do
        before do
          @csv_file = Rails.root.join("spec", "fixtures", "files", "extra_columns.csv")
          CSV.open(@csv_file, "w") do |csv|
            csv << ["ユニークID", "物件名", "管理会社", "住所", "部屋番号", "賃料", "広さ", "建物の種類", "築年数", "最寄り駅", "備考"]
            csv << ["EXT001", "エクストラタワー", "ABC管理", "東京都品川区1-1", "801", "200000", "75.5", "マンション", "5年", "品川駅", "ペット可"]
            csv << ["EXT002", "グリーンパレス", "XYZ不動産", "神奈川県横浜市2-2", "402", "150000", "60.0", "アパート", "10年", "横浜駅", "駐車場あり"]
            csv << ["EXT003", "シーサイドハウス", "DEF管理", "千葉県浦安市3-3", "", "280000", "110.5", "一戸建て", "新築", "新浦安駅", "オーシャンビュー"]
            csv << ["EXT004", "フォレストコート", "GHI不動産", "埼玉県川口市4-4", "203", "120000", "52.0", "マンション", "8年", "川口駅", "リノベーション済"]
          end
        end

        after do
          File.delete(@csv_file) if File.exist?(@csv_file)
        end

        it "creates new records" do
          visit buildings_path
          click_link "Upload CSV"
          attach_file "csv_file", @csv_file
          click_button "Upload"

          # Run all enqueued jobs
          perform_enqueued_jobs

          # Visit the buildings page again to see the updated data
          visit buildings_path
          # Verify all buildings are created despite extra columns
          within("tbody") do
            # Check EXT001
            ext001_row = find("tr", text: "EXT001")
            within(ext001_row) do
              expect(page).to have_text("エクストラタワー")
              expect(page).to have_text("東京都品川区1-1")
              expect(page).to have_text("801")
              expect(page).to have_text("200000")
              expect(page).to have_text("75.5")
              expect(page).to have_text("マンション")
            end
            # Check EXT002
            ext002_row = find("tr", text: "EXT002")
            within(ext002_row) do
              expect(page).to have_text("グリーンパレス")
              expect(page).to have_text("神奈川県横浜市2-2")
              expect(page).to have_text("402")
              expect(page).to have_text("150000")
              expect(page).to have_text("60.0")
              expect(page).to have_text("アパート")
            end
            # Check EXT003
            ext003_row = find("tr", text: "EXT003")
            within(ext003_row) do
              expect(page).to have_text("シーサイドハウス")
              expect(page).to have_text("千葉県浦安市3-3")
              expect(page).to have_text("280000")
              expect(page).to have_text("110.5")
              expect(page).to have_text("一戸建て")
            end
            # Check EXT004
            ext004_row = find("tr", text: "EXT004")
            within(ext004_row) do
              expect(page).to have_text("フォレストコート")
              expect(page).to have_text("埼玉県川口市4-4")
              expect(page).to have_text("203")
              expect(page).to have_text("120000")
              expect(page).to have_text("52.0")
              expect(page).to have_text("マンション")
            end
            # Verify original buildings are still there
            expect(page).to have_text("BLD001")
            expect(page).to have_text("BLD002")
          end
          # Verify the extra columns were ignored and not displayed
          expect(page).not_to have_text("ABC管理")
          expect(page).not_to have_text("XYZ不動産")
          expect(page).not_to have_text("品川駅")
          expect(page).not_to have_text("ペット可")
          # Verify count (2 original + 4 new = 6)
          expect(Building.count).to eq(6)
        end
      end
      context "becuase the columns have unexpected names" do
        before do
          @csv_file = Rails.root.join("spec", "fixtures", "files", "bad_column_names.csv")
          CSV.open(@csv_file, "w") do |csv|
            # Using incorrect column names - e.g., "ID" instead of "ユニークID", "建物名" instead of "物件名", "タイプ" instead of "建物の種類"
            csv << ["ID", "建物名", "住所", "部屋番号", "賃料", "広さ", "タイプ"]
            csv << ["BAD001", "バッドタワー", "東京都中央区1-1", "501", "180000", "70.5", "マンション"]
            csv << ["BAD002", "バッドハウス", "大阪府大阪市2-2", "", "250000", "95.0", "一戸建て"]
            csv << ["BAD003", "バッドアパート", "福岡県福岡市3-3", "303", "120000", "55.5", "アパート"]
          end
        end

        after do
          File.delete(@csv_file) if File.exist?(@csv_file)
        end

        it "fails and creates no records" do
          # Get initial count
          initial_count = Building.count
          visit buildings_path
          click_link "Upload CSV"
          attach_file "csv_file", @csv_file
          click_button "Upload"

          # Run all enqueued jobs
          perform_enqueued_jobs

          # Visit the buildings page again
          visit buildings_path
          # Verify no new buildings were created
          expect(Building.count).to eq(initial_count)
          # Verify the bad data is not present
          expect(page).not_to have_text("BAD001")
          expect(page).not_to have_text("BAD002")
          expect(page).not_to have_text("BAD003")
          expect(page).not_to have_text("バッドタワー")
          expect(page).not_to have_text("バッドハウス")
          expect(page).not_to have_text("バッドアパート")
          # Verify original buildings are still there
          expect(page).to have_text("BLD001")
          expect(page).to have_text("Test Apartment")
          expect(page).to have_text("BLD002")
          expect(page).to have_text("Test House")
        end
      end
      context "becuase it is missing important columns" do
        before do
          @csv_file = Rails.root.join("spec", "fixtures", "files", "missing_columns.csv")
          CSV.open(@csv_file, "w") do |csv|
            # Missing the "物件名" (name) column entirely
            csv << ["ユニークID", "住所", "部屋番号", "賃料", "広さ", "建物の種類"]
            csv << ["MISS001", "東京都新宿区1-1", "601", "190000", "68.5", "マンション"]
            csv << ["MISS002", "大阪府大阪市2-2", "", "230000", "105.0", "一戸建て"]
            csv << ["MISS003", "名古屋市中区3-3", "203", "110000", "48.5", "アパート"]
            csv << ["MISS004", "福岡県福岡市4-4", "405", "145000", "62.0", "マンション"]
          end
        end

        after do
          File.delete(@csv_file) if File.exist?(@csv_file)
        end

        it "fails and creates no records" do
          # Get initial count
          initial_count = Building.count
          visit buildings_path
          click_link "Upload CSV"
          attach_file "csv_file", @csv_file
          click_button "Upload"

          # Run all enqueued jobs
          perform_enqueued_jobs

          # Visit the buildings page again
          visit buildings_path
          # Verify no new buildings were created
          expect(Building.count).to eq(initial_count)
          # Verify the data with missing columns is not present
          expect(page).not_to have_text("MISS001")
          expect(page).not_to have_text("MISS002")
          expect(page).not_to have_text("MISS003")
          expect(page).not_to have_text("MISS004")
          expect(page).not_to have_text("東京都新宿区1-1")
          expect(page).not_to have_text("大阪府大阪市2-2")
          expect(page).not_to have_text("名古屋市中区3-3")
          # Verify original buildings are still there
          expect(page).to have_text("BLD001")
          expect(page).to have_text("Test Apartment")
          expect(page).to have_text("BLD002")
          expect(page).to have_text("Test House")
        end
      end
      context "because some columns lack data" do # for example, unique_id or structure_type
        context " its missing some important info like name or unique_id" do
          before do
            @csv_file = Rails.root.join("spec", "fixtures", "files", "partial_missing_data.csv")
            CSV.open(@csv_file, "w") do |csv|
              csv << ["ユニークID", "物件名", "住所", "部屋番号", "賃料", "広さ", "建物の種類"]
              # Valid row
              csv << ["PART001", "パーシャルタワー", "東京都渋谷区1-1", "701", "210000", "72.5", "マンション"]
              # Missing unique_id - should be skipped
              csv << ["", "ミッシングIDハウス", "大阪府大阪市2-2", "", "180000", "95.0", "一戸建て"]
              # Valid row
              csv << ["PART003", "グッドアパート", "福岡県福岡市3-3", "303", "130000", "58.5", "アパート"]
              # Missing name - should be skipped
              csv << ["PART004", "", "名古屋市中区4-4", "404", "155000", "65.0", "マンション"]
              # Valid row
              csv << ["PART005", "バリッドハウス", "京都府京都市5-5", "", "240000", "105.0", "一戸建て"]
              # Missing unique_id and name - should be skipped
              csv << ["", "", "千葉県千葉市6-6", "606", "125000", "52.0", "アパート"]
              # Valid row
              csv << ["PART007", "ラストマンション", "埼玉県川口市7-7", "707", "195000", "78.5", "マンション"]
            end
          end

          after do
            File.delete(@csv_file) if File.exist?(@csv_file)
          end

          it "creates those records that are OK but not those that are missing data" do
            # Get initial count
            initial_count = Building.count
            visit buildings_path
            click_link "Upload CSV"
            attach_file "csv_file", @csv_file
            click_button "Upload"
            # Run all enqueued jobs
            perform_enqueued_jobs
            # Visit the buildings page again
            visit buildings_path
            # Verify only valid records were created (4 valid rows)
            expect(Building.count).to eq(initial_count + 4)
            # Verify valid records are present
            within("tbody") do
              # Check PART001 - valid
              part001_row = find("tr", text: "PART001")
              within(part001_row) do
                expect(page).to have_text("パーシャルタワー")
                expect(page).to have_text("東京都渋谷区1-1")
                expect(page).to have_text("701")
                expect(page).to have_text("210000")
                expect(page).to have_text("72.5")
                expect(page).to have_text("マンション")
              end
              # Check PART003 - valid
              part003_row = find("tr", text: "PART003")
              within(part003_row) do
                expect(page).to have_text("グッドアパート")
                expect(page).to have_text("福岡県福岡市3-3")
                expect(page).to have_text("303")
                expect(page).to have_text("130000")
                expect(page).to have_text("58.5")
                expect(page).to have_text("アパート")
              end
              # Check PART005 - valid
              part005_row = find("tr", text: "PART005")
              within(part005_row) do
                expect(page).to have_text("バリッドハウス")
                expect(page).to have_text("京都府京都市5-5")
                expect(page).to have_text("240000")
                expect(page).to have_text("105.0")
                expect(page).to have_text("一戸建て")
              end
              # Check PART007 - valid
              part007_row = find("tr", text: "PART007")
              within(part007_row) do
                expect(page).to have_text("ラストマンション")
                expect(page).to have_text("埼玉県川口市7-7")
                expect(page).to have_text("707")
                expect(page).to have_text("195000")
                expect(page).to have_text("78.5")
                expect(page).to have_text("マンション")
              end
            end
            # Verify invalid records were not created
            expect(page).not_to have_text("ミッシングIDハウス")  # Missing unique_id
            expect(page).not_to have_text("PART004")  # Missing name
            expect(page).not_to have_text("千葉県千葉市6-6")  # Missing both unique_id and name
            # Verify original buildings are still there
            expect(page).to have_text("BLD001")
            expect(page).to have_text("BLD002")
          end
        end
        context "because the room number is missing on a structure_type that validates it" do
          before do
            @csv_file = Rails.root.join("spec", "fixtures", "files", "missing_room_numbers.csv")
            CSV.open(@csv_file, "w") do |csv|
              csv << ["ユニークID", "物件名", "住所", "部屋番号", "賃料", "広さ", "建物の種類"]
              # Valid: マンション with room number
              csv << ["ROOM001", "ルームタワー", "東京都港区1-1", "801", "220000", "82.5", "マンション"]
              # Invalid: マンション without room number - should be skipped
              csv << ["ROOM002", "ノールームマンション", "大阪府大阪市2-2", "", "190000", "75.0", "マンション"]
              # Valid: 一戸建て without room number (room number not required)
              csv << ["ROOM003", "ハッピーハウス", "福岡県福岡市3-3", "", "260000", "115.0", "一戸建て"]
              # Invalid: アパート without room number - should be skipped
              csv << ["ROOM004", "ノールームアパート", "名古屋市中区4-4", "", "140000", "62.0", "アパート"]
              # Valid: アパート with room number
              csv << ["ROOM005", "グッドアパート", "京都府京都市5-5", "505", "135000", "58.5", "アパート"]
              # Valid: 一戸建て with room number (optional but allowed)
              csv << ["ROOM006", "ナンバーハウス", "千葉県千葉市6-6", "101", "280000", "125.0", "一戸建て"]
              # Invalid: マンション without room number - should be skipped
              csv << ["ROOM007", "エンプティマンション", "埼玉県川口市7-7", "", "175000", "68.0", "マンション"]
            end
          end

          after do
            File.delete(@csv_file) if File.exist?(@csv_file)
          end

          it "does not create that record, but creates other records" do
            # Get initial count
            initial_count = Building.count
            visit buildings_path
            click_link "Upload CSV"
            attach_file "csv_file", @csv_file
            click_button "Upload"
            # Run all enqueued jobs
            perform_enqueued_jobs
            # Visit the buildings page again
            visit buildings_path
            # Verify only valid records were created (4 valid rows)
            expect(Building.count).to eq(initial_count + 4)
            # Verify valid records are present
            within("tbody") do
              # Check ROOM001 - valid マンション with room
              room001_row = find("tr", text: "ROOM001")
              within(room001_row) do
                expect(page).to have_text("ルームタワー")
                expect(page).to have_text("東京都港区1-1")
                expect(page).to have_text("801")
                expect(page).to have_text("220000")
                expect(page).to have_text("82.5")
                expect(page).to have_text("マンション")
              end
              # Check ROOM003 - valid 一戸建て without room
              room003_row = find("tr", text: "ROOM003")
              within(room003_row) do
                expect(page).to have_text("ハッピーハウス")
                expect(page).to have_text("福岡県福岡市3-3")
                expect(page).to have_text("260000")
                expect(page).to have_text("115.0")
                expect(page).to have_text("一戸建て")
              end
              # Check ROOM005 - valid アパート with room
              room005_row = find("tr", text: "ROOM005")
              within(room005_row) do
                expect(page).to have_text("グッドアパート")
                expect(page).to have_text("京都府京都市5-5")
                expect(page).to have_text("505")
                expect(page).to have_text("135000")
                expect(page).to have_text("58.5")
                expect(page).to have_text("アパート")
              end
              # Check ROOM006 - valid 一戸建て with optional room
              room006_row = find("tr", text: "ROOM006")
              within(room006_row) do
                expect(page).to have_text("ナンバーハウス")
                expect(page).to have_text("千葉県千葉市6-6")
                expect(page).to have_text("101")
                expect(page).to have_text("280000")
                expect(page).to have_text("125.0")
                expect(page).to have_text("一戸建て")
              end
            end
            # Verify invalid records were not created
            expect(page).not_to have_text("ROOM002")  # マンション without room
            expect(page).not_to have_text("ノールームマンション")
            expect(page).not_to have_text("ROOM004")  # アパート without room
            expect(page).not_to have_text("ノールームアパート")
            expect(page).not_to have_text("ROOM007")  # マンション without room
            expect(page).not_to have_text("エンプティマンション")
            # Verify original buildings are still there
            expect(page).to have_text("BLD001")
            expect(page).to have_text("BLD002")
          end
        end
      end
    end
  end

  context "when the CSV file is not a CSV file" do
    before do
      @txt_file = Rails.root.join("spec", "fixtures", "files", "not_a_csv.txt")

      # Create a plain text file that's not CSV format
      File.open(@txt_file, "w") do |file|
        file.puts "This is not a CSV file"
        file.puts "It's just plain text"
        file.puts "ユニークID: TEST001"
        file.puts "物件名: Test Building"
        file.puts "住所: Tokyo"
      end
    end

    after do
      File.delete(@txt_file) if File.exist?(@txt_file)
    end

    it "does not update any models" do
      # Get initial count
      initial_count = Building.count

      visit buildings_path
      click_link "Upload CSV"
      attach_file "csv_file", @txt_file
      click_button "Upload"

      # Run all enqueued jobs
      perform_enqueued_jobs

      # Visit the buildings page again
      visit buildings_path

      # Verify no new buildings were created
      expect(Building.count).to eq(initial_count)

      # Verify the data from the text file is not present
      expect(page).not_to have_text("TEST001")
      expect(page).not_to have_text("Test Building")

      # Verify original buildings are still there
      expect(page).to have_text("BLD001")
      expect(page).to have_text("Test Apartment")
      expect(page).to have_text("BLD002")
      expect(page).to have_text("Test House")
    end
  end
end
