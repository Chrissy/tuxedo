class RenameAkaToAkaId < ActiveRecord::Migration
  def change
    rename_column :components, :aka, :aka_id
  end
end
