class AddRecipesToComponents < ActiveRecord::Migration
  def change
    change_table :components do |t|
      t.text :recipes
    end
  end
end
