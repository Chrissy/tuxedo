# frozen_string_literal: true

class AddSkipSubcomponentSearchToComponents < ActiveRecord::Migration[5.2]
  def change
    change_table :components do |t|
      t.boolean :skip_subcomponent_search
    end
  end
end
