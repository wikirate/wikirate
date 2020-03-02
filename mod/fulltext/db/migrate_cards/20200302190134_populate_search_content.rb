# -*- encoding : utf-8 -*-

class PopulateSearchContent < Card::Migration
  def up
    Card.find_each do |card|
      card.include_set_modules
      card.update_column :search_content, card.generate_search_content
    end
  end
end
