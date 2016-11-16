# Refer to wikirate_topic/all_companies.rb

include Card::CachedCount

# # recount companies related to topic when ...

# # ... <source>+company is edited
# ensure_set { TypePlusRight::Source::WikirateCompany }
# recount_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
#   names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
#   names.map do |company_name|
#     Card.fetch company_name.to_name.trait(:wikirate_topic)
#   end
# end

# # ... <note>+company is edited
# ensure_set { TypePlusRight::Claim::WikirateCompany }
# recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
#   names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
#   names.map do |company_name|
#     Card.fetch company_name.to_name.trait(:wikirate_topic)
#   end
# end

# in case sth trigger refresh manually
def calculate_count _changed_card=nil
  left.related_companies.size
end
