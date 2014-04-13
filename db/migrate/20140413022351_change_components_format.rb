class ChangeComponentsFormat < ActiveRecord::Migration
  def up
    change_column :recipes, :components, :text  
  end

  def down
    change_column :recipes, :components, :string  
  end
end
