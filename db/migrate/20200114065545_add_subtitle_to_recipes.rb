# frozen_string_literal: true

class AddSubtitleToRecipes < ActiveRecord::Migration[5.2]
  def change
    change_table :recipes do |t|
      t.text :subtitle
    end
  end
end
