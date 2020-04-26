# frozen_string_literal: true

class AddSubstitutesToComponents < ActiveRecord::Migration[5.2]
  def change
    change_table :components do |t|
      t.text :substitutes_as_markdown
    end
  end
end
