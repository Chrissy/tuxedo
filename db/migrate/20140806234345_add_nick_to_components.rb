class AddNickToComponents < ActiveRecord::Migration
  def change
    change_table :components do |t|
      t.string :nick
    end
  end
end
