# -*- encoding : utf-8 -*-

class CachedCountTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :counts if table_exists? :counts
    create_table :counts do |t|
      t.integer :left_id
      t.integer :right_id
      t.integer :value
    end

    add_index :counts, :right_id, name: "left_id_index"
    add_index :counts, :left_id, name: "right_id_index"
  end

  def down
    drop_table :counts
  end
end
