class ChangeComponentAkasToPsuedonyms < ActiveRecord::Migration
  def change
    rename_column :components, :akas_as_markdown, :pseudonyms_as_markdown
  end
end
