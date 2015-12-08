include Card::CachedCount
# {
#   "type":"topic",
#   "referred_to_by":{
#     "left":{
#       "type":["in","Note","Source"],
#       "right_plus":["company",{"refer_to":"_1"}]
#     },
#     "right":"topic"
#   }
# }

expired_cached_count_cards set: TypePlusRight::Source::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch "#{company_name}+#{Card[:wikirate_topic].name}"
  end
end

expired_cached_count_cards set: TypePlusRight::Claim::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch "#{company_name}+#{Card[:wikirate_topic].name}"
  end
end
