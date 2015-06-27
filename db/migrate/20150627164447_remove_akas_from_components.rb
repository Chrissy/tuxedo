class RemoveAkasFromComponents < ActiveRecord::Migration
  def change
    remove_column :components, :aka_id, :string
    remove_column :components, :akas, :text    
  end
end
