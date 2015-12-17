include Card::CachedCount

# recount topics associated with a company whenever <source>+company is edited
recount_trigger Source::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# recount topics associated with a company whenever <note>+company is edited
recount_trigger Claim::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# FIXME: should also count connections via metrics.