class AddAkaMarkdownToComponents < ActiveRecord::Migration
  def change
    change_table :components do |t|
      t.string :akas_as_markdown
    end
  end
end
