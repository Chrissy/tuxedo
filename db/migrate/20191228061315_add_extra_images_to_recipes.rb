class AddExtraImagesToRecipes < ActiveRecord::Migration[5.2]
  def change
    change_table :recipes do |t|
      t.text :image2
      t.text :image3
    end
  end
end
