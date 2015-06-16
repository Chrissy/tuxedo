class AddContentAsMarkdownToComponents < ActiveRecord::Migration
  def change
    change_table :components do |t|
      t.text :list_as_markdown
    end
  end
end
