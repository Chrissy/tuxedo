class AddSlugToEverything < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.string :slug, :unique => true
    end
    change_table :components do |t|
      t.string :slug, :unique => true
    end
    change_table :lists do |t|
      t.string :slug, :unique => true
    end
  end
end
