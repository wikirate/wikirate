# -*- encoding : utf-8 -*-

class AddSourcesAndCommentsToLookup < Cardio::Migration::DeckStructure
  def up
    add_column :answers, :source_count, :integer
    add_column :answers, :source_url, :string, limit: 1024
    add_column :answers, :comments, :string, limit: 1024
  end
end
