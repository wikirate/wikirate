class AddFulltextIndexing < ActiveRecord::Migration[6.0]
  def up
    add_column :cards, :search_content, :text, limit: 1.megabyte
    add_index :cards, :search_content, name: "search_content_index", type: :fulltext
  end

  def down
    remove_column :cards, :search_content
  end
end
