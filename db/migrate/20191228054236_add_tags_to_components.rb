class AddTagsToComponents < ActiveRecord::Migration[5.2]
  def change
    change_table :components do |t|
      t.text :tags_as_text
    end
  end
end
