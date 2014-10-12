class AddImageToLists < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.string :image
    end
  end
end
