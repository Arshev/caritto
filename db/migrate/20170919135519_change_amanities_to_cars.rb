class ChangeAmanitiesToCars < ActiveRecord::Migration[5.1]
  def change
    change_table :cars do |t|
      t.rename :home_type, :car_type
      t.remove :room_type
      t.remove :accommodate
      t.remove :bed_room
      t.remove :bath_room
      t.rename :listing_name, :car_name
      t.rename :summary, :description
      t.string :fuel
      t.string :mileage
      t.integer :people_capacity
      t.string :transmission
      t.integer :year
      t.string :engine_capacity
      t.string :body_color
      t.integer :number_doors
      t.rename :is_tv, :navigator
      t.rename :is_kitchen, :is_leather
      t.rename :is_heating, :for_kids
      t.rename :is_internet, :is_mp3
      t.string :extra_field
      t.boolean :abroad
      t.boolean :smoking
      t.boolean :pets
    end
  end
end
