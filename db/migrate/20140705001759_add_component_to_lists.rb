class AddComponentToLists < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.integer :component
    end
  end
end
