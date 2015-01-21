class AddNeverMakeMeTallToEverything < ActiveRecord::Migration
  def change
    change_table :recipes do |t|
      t.boolean :never_make_me_tall
    end
    change_table :components do |t|
      t.boolean :never_make_me_tall
    end
    change_table :lists do |t|
      t.boolean :never_make_me_tall
    end
  end
end
