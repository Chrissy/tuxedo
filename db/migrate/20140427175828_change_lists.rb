class ChangeLists < ActiveRecord::Migration
  def change
    rename_column :lists, :nodes, :list_element_ids
  end
end
