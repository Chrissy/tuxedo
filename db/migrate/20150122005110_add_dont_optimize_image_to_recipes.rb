class AddDontOptimizeImageToRecipes < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.boolean :dont_compress_image
    end
  end
end
