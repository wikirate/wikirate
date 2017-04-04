# -*- encoding : utf-8 -*-

class RemoveCachedCountCards < Card::Migration
  disable_ddl_transaction!

  def up
    remove type: :metric, plus_right: :source
    remove type: :metric, plus_right: :wikirate_company
    remove type: :metric, plus_right: :value
    remove type: :wikirate_company, plus_right: :metric
    remove type: :wikirate_company, plus_right: :wikirate_topic
    remove type: :wikirate_company, plus_right: :source
    remove type: :wikirate_company, plus_right: :project
  end

  def remove type: , plus_right:
    remove_cached_counts left: { type_id: Card::Codename[type] },
                         right_id: Card::Codename[plus_right]
    Card[type, plus_right, :type_plus_right, :structure].delete
  end

  def remove_cached_counts wql
    Card.search(wql).each do |card|
      card.update_cached_count
      card.delete
    end
  end
end
