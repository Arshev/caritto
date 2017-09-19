class AddInstantToCars < ActiveRecord::Migration[5.1]
  def change
    add_column :cars, :instant, :integer, default: 1
  end
end
