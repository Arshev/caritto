class RenameRoomsToCars < ActiveRecord::Migration[5.1]
  def change
    rename_table :rooms, :cars
  end
end
