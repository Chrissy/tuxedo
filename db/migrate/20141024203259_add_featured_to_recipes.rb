class AddFeaturedToRecipes < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.boolean :featured
    end
  end
end
