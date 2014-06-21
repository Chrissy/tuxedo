class AddListToComponents < ActiveRecord::Migration
  def change
    change_table :components do |t|
      t.integer :list
    end
  end
end
