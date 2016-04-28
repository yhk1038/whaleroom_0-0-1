class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :title
      t.string :artist
      t.string :lowkey
      t.string :highkey
      t.text  :tjnum
      t.text  :gininum

      t.timestamps null: false
    end
  end
end
