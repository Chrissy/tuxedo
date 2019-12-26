class CreateSubcomponents < ActiveRecord::Migration[5.2]
  def change
    create_table :subcomponents do |t|
      t.references :component, foreign_key: true
      t.string :name
      t.timestamps
    end
  end
end
