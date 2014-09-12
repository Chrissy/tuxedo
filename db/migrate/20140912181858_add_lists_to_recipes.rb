class AddListsToRecipes < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.string :list_ids
    end
  end
end
