class AddIllustrationToComponents < ActiveRecord::Migration[5.2]
  def change
    change_table :components do |t|
      t.text :illustration
    end
  end
end
