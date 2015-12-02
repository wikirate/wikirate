include Card::CachedCount

expired_cached_count_cards do |changed_card|
  # "right_plus":[["topic",{"refer_to":"_2"}],
  #  ["_ll",{"right_plus":["*cached count",{"ne":0}]}] ]
  expired_cached_cards = []
  if (r = changed_card.right)
    # metric's topic changes
    analysis_type_id = Card::WikirateAnalysisID
    if (l = changed_card.left) && l.type_code == :metric &&
       r.key == 'topic' && changed_card.type_code == :pointer
      # find all related analysis to the topic
      card_names = changed_card.item_names.unshift('in')
      expired_cached_cards.cancat(Card.search type_id: analysis_type_id,
                                              right: card_names,
                                              append: 'metric')
    end
    # metric value sets cached count
    if r.id == CachedCountID && (l = changed_card.left) && (ll = l.left) &&
       (lr = l.right) && ll.type_code == :metric &&
       lr.type_code == :wikirate_company
      # find all related analysis to the company and metric's topics
      search_args = { type_id: analysis_type_id, left: lr.name,
                      append: 'metric' }
      if (topic_card = ll.fetch trait: :wikirate_topic) &&
         (topic_cards = topic_card.item_names) && topic_cards.size > 0
        search_args.merge(right: topic_cards.unshift('in'))
      end
      expired_cached_cards.concat(Card.search search_args)
    end
  end
  expired_cached_cards.uniq
end
