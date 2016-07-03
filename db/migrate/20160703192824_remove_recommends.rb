class RemoveRecommends < ActiveRecord::Migration
  def change
    remove_column :recipes, :recommends, :text
  end
end
