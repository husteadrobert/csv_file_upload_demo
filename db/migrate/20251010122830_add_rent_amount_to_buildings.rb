class AddRentAmountToBuildings < ActiveRecord::Migration[7.1]
  def change
    add_column :buildings, :rent_amount, :integer
  end
end
