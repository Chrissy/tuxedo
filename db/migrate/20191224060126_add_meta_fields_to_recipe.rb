class AddMetaFieldsToRecipe < ActiveRecord::Migration[5.2]
  def change
    change_table :recipes do |t|
      t.integer :rating
      t.text :adapted_from
    end

    remove_column :recipes, :dont_compress_image, :boolean
  end
end
