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
    remove type: :wikirate_topic, plus_right: :wikirate_company
    remove type: :wikirate_analysis, plus_right: :source
    remove type: :wikirate_analysis, plus_right: :claim
    remove type: :wikirate_analysis, plus_right: :metric
    remove_ltype_rtype :metric, :wikirate_company
    remove_counts_with_missing_left_parts
    remove_contribution_counts
    Card::Cache.reset_all
    Card.empty_trash
    remove_empty_analyses
    Card::Cache.reset_all
    Card.empty_trash
  end

  def remove type:, plus_right:
    puts "remove #{type}+#{plus_right}+type_plus_right"
    remove_cached_counts left: { type_id: Card::Codename.id(type) },
                         right_id: Card::Codename.id(plus_right)
    card = Card[type, plus_right, :type_plus_right, :structure]
    card.delete! if card
  end

  def remove_ltype_rtype ltype, rtype
    trash_all left: { left: { type_id: Card::Codename.id(ltype) },
                          right: { type_id: Card::Codename.id(rtype) } },
              right: { codename: "cached_count" }
  end

  def remove_cached_counts wql
    count_ids = Card.search(left: wql, right: { codename: "cached_count" }, return: :id )
    search_ids = count_ids.map do |id|
      search_id = Card.quick_fetch(id).left_id
      if (search_card = Card[search_id])
        search_card.update_cached_count
      end
      search_id
    end
    trash_ids count_ids
    trash_ids search_ids
  end

  def remove_contribution_counts
    trash_all right: { codename: "contribution_count" }
    trash_all right: { codename: "direct_contribution_count" }
  end

  def remove_empty_analyses
    # find all analyses without fields (assuming there is no "+wikirate bot" field)
    trash_all type: { codename: "wikirate_analysis" },
              not: { right_plus: [{ not: { id: 1 } }, {}]}
  end

  def remove_counts_with_missing_left_parts
    # no left_id
    ids = Card.where(left_id: nil, right_id: Card::CachedCountID)
              .pluck(:id)
    update_and_trash ids

    # left_id doesn't exist
    left_join = "LEFT JOIN cards AS left_cards ON left_cards.id = cards.left_id"
    ids = Card.joins(left_join)
              .where("left_cards.id IS NULL AND cards.right_id = ?", Card::CachedCountID)
              .pluck(:id)
    update_and_trash ids

    # left.left_id doesn't exist
    ll_join = "LEFT JOIN cards AS ll_cards ON ll_cards.id = left_cards.left_id"
    Card.joins(left_join).joins(ll_join)
        .where("ll_cards.id IS NULL AND cards.right_id = ?", Card::CachedCountID)
        .update_all(trash: true)
  end

  def trash_all wql
    trash_ids Card.search wql.merge(return: :id)
  end

  def update_and_trash ids
    ids.each do |id|
      next unless (card = Card.fetch(Card.fetch_name(id).to_name.left))
      card.try :update_cached_count
    end
    trash_ids ids
  end

  def trash_ids ids
    Card.where(id: ids).update_all trash: true
  end
end


