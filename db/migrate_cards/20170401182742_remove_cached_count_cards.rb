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
    remove type: :wikirate_company, plus_right: :claim
    remove type: :wikirate_company, plus_right: :analyses_with_articles
    remove type: :wikirate_topic, plus_right: :source
    remove type: :wikirate_topic, plus_right: :claim
    remove type: :wikirate_topic, plus_right: :analyses_with_articles
    remove type: :wikirate_topic, plus_right: :metric
    remove type: :wikirate_topic, plus_right: :project
    remove type: :wikirate_topic, plus_right: :wikirate_company
    remove_ltype_rtype :metric, :wikirate_company
    remove_contribution_counts
    Card::Cache.reset_all
    Card.empty_trash
  end

  def remove type:, plus_right:
    remove_cached_counts left: { type_id: Card::Codename[type] },
                         right_id: Card::Codename[plus_right]
    card = Card[type, plus_right, :type_plus_right, :structure]
    card.delete! if card
  end

  def remove_ltype_rtype ltype, rtype
    Card.search(left: { left: { type_id: Card::Codename[ltype] },
                        right: { type_id: Card::Codename[rtype] } },
                right: { codename: "cached_count" }).each do |card|
         card.delete!
    end
  end

  def remove_cached_counts wql
    Card.search(wql).each do |card|
      card.update_cached_count
      card.delete!
    end
  end

  def remove_contribution_counts
    [{ right: { codename: "contribution_count" } },
     { right: { codename: "direct_contribution_count" } }].each do |wql|
      Card.search(wql).each do |card|
        card.delete
      end
    end
  end
end
