class ChangeListElementIds < ActiveRecord::Migration
  def change
    rename_column :lists, :list_element_ids, :element_ids
  end
end
