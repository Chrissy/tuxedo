class ChangeWhyToField < ActiveRecord::Migration
  def change
    rename_column :relationships, :why, :field
  end
end
