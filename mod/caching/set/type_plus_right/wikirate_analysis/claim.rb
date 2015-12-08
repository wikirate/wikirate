include Card::CachedCount

ensure_set { TypePlusRight::Claim::WikirateCompany }
expired_cached_count_cards set: TypePlusRight::Claim::WikirateCompany do |changed_card|
    # find all related analysis
    card_names = changed_card.item_names.unshift('in')
    Card.search type_id: Card::WikirateAnalysisID, append: 'claim',
                left: card_names
end

ensure_set { TypePlusRight::Claim::WikirateTopic }
expired_cached_count_cards set: TypePlusRight::Claim::WikirateTopic do |changed_card|
    # find all related analysis
    card_names = changed_card.item_names.unshift('in')
    Card.search type_id: Card::WikirateAnalysisID, append: 'claim',
                right: card_names
end
