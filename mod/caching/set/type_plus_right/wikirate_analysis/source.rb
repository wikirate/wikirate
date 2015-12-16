# cache # of sources that are tagged with the company (=_ll)
# and the topic (=_lr)
# query for the items that get counted
# (analysis+source+*type_plus_right+*structure):
#  "type":"Source",
#  "right_plus":[["Company", {"refer_to":"_1"}],["Topic",{"refer_to":"_2"}]]
include Card::CachedCount

ensure_set { TypePlusRight::Source::WikirateCompany }
expired_cached_count_cards set: TypePlusRight::Source::WikirateCompany do |changed_card|
  Card.search type_id: Card::WikirateAnalysisID, append: 'source',
              left: changed_card.item_names.unshift('in')
end

ensure_set { TypePlusRight::Source::WikirateTopic }
expired_cached_count_cards set: TypePlusRight::Source::WikirateTopic do |changed_card|
  Card.search type_id: Card::WikirateAnalysisID, append: 'source',
              right: changed_card.item_names.unshift('in')
end