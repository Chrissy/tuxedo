class AddFeaturedRecipesToRecipes < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.text :recommends
    end
  end
end
