class AddAkasToComponents < ActiveRecord::Migration
  def change
    change_table :components do |t|
      t.text :akas
      t.string :aka_id
    end
  end
end
