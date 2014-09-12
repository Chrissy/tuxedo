class AddTimestampsToRecipesAndComponents < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.datetime 'created_at' 
      t.datetime 'updated_at'
    end
    change_table :components do |t|
      t.datetime 'created_at' 
      t.datetime 'updated_at'
    end
  end
end
