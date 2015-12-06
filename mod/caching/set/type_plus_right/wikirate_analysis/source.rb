include Card::CachedCount

expired_cached_count_cards do |changed_card|
  if (l = changed_card.left) && l.type_code == :source &&
     (r = changed_card.right) && (r.key == 'company' || r.key == 'topic') &&
     changed_card.type_code == :pointer
    # find all related analysis
    card_names = changed_card.item_names.unshift('in')
    side = case r.key
           when 'company' then :left
           when 'topic' then :right
           end
    Card.search type_id: Card::WikirateAnalysisID, append: 'source',
                side => card_names
  end
end
