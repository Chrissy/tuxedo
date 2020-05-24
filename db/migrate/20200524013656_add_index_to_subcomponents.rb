class AddIndexToSubcomponents < ActiveRecord::Migration[5.2]
  def change
    change_table :subcomponents do |t|
      t.integer :index
    end
  end
end
