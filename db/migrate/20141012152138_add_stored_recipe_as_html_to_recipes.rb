class AddStoredRecipeAsHtmlToRecipes < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.text :stored_recipe_as_html
    end
  end
end
