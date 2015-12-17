include Card::CachedCount
#{
#   "type":"topic",
#   "referred_to_by":{
#     "or":{
#       "left":{
#           "type":["in","Note","Source"],
#           "right_plus":["company",{"refer_to":"_1"}]
#       },
#       "and":{
#         "type":"Metric",
#         "right_plus":["_1",{}]
#        }
#     },
#     "right":"topic"
#   }
# }

expired_cached_count_cards set: TypePlusRight::Source::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company|
    Card.fetch company.to_name.trait(:wikirate_topic)
  end
end

expired_cached_count_cards set: TypePlusRight::Claim::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company|
    Card.fetch company.to_name.trait(:wikirate_topic)
  end
end

expired_cached_count_cards set: TypePlusRight::Metric::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company|
    Card.fetch company.to_name.trait(:wikirate_topic)
  end
end
