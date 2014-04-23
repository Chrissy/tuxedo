class FixColumnNames < ActiveRecord::Migration
  def change
    rename_column :components, :recipes, :recipe_ids
    rename_column :recipes, :components, :component_ids
  end
end
