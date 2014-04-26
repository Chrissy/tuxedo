class AddImageToComponents < ActiveRecord::Migration
  def change
    change_table :components do |t|
      t.text :image
    end
  end
end
