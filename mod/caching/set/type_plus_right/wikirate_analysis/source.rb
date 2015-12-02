include Card::CachedCount

expired_cached_count_cards do |changed_card|
  if (l = changed_card.left) && l.type_code == :source &&
     (r = changed_card.right) && (r.key == 'company' || r.key == 'topic') &&
     changed_card.type_code == :pointer
    
    # find all related analysis
    card_names = changed_card.item_names.unshift('in')
    analysis_type_id = Card::WikirateAnalysisID
    case r.key
    when 'company'
      Card.search type_id: analysis_type_id, left: card_names, append: 'source'
    when 'topic'
      Card.search type_id: analysis_type_id, right: card_names, append: 'source'
    end
  end
end
