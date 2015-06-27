class CreatePseudonyms < ActiveRecord::Migration
  def change
    create_table :pseudonyms do |t|
      t.references :pseudonymable, polymorphic: true
      t.string :name
      t.timestamps
    end
  end
end
