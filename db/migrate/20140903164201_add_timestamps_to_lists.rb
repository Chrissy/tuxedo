class AddTimestampsToLists < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.datetime 'created_at' 
      t.datetime 'updated_at'
    end
  end
end
