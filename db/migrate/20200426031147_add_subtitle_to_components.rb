class AddSubtitleToComponents < ActiveRecord::Migration[5.2]
  def change
    change_table :components do |t|
      t.text :subtitle
    end
  end
end
