class AddTagsToRecipes < ActiveRecord::Migration[5.2]
  def change
    change_table :recipes do |t|
      t.string :tags_as_text
    end
  end
end
