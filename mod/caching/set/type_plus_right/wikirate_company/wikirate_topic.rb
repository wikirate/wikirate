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

# recount topics associated with a company whenever <source>+company is edited
ensure_set { TypePlusRight::Source::WikiRateCompany }
recount_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# recount topics associated with a company whenever <note>+company is edited
ensure_set { TypePlusRight::Claim::WikiRateCompany }
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# FIXME: should also count connections via metrics.
