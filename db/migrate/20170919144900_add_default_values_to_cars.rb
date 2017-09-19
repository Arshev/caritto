class AddDefaultValuesToCars < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:cars, :navigator, false)
    change_column_default(:cars, :is_air, false)
    change_column_default(:cars, :is_mp3, false)
    change_column_default(:cars, :is_leather, false)
    change_column_default(:cars, :for_kids, false)
    change_column_default(:cars, :abroad, false)
    change_column_default(:cars, :smoking, false)
    change_column_default(:cars, :pets, false)
    add_column :cars, :for_taxi, :boolean, default: false
  end
end
