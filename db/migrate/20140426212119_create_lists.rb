class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.text :content_as_markdown
      t.text :nodes
    end
  end
end
