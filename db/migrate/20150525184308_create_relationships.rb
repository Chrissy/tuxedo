class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.references :relatable, polymorphic: true, index: true
      t.integer :child_id
      t.string :child_type
      t.string :why
      t.string :key
      t.timestamps
    end
  end
end
