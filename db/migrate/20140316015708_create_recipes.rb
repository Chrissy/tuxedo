class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :recipe
      t.text :description
      t.string :image
      t.string :components
      t.boolean :published
      t.datetime :last_updated
      t.text :instructions
    end
  end
end
