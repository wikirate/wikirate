include Card::CachedCount

# recount companies related to topic when ...

# ... <source>+company is edited
ensure_set { TypePlusRight::Source::WikirateCompany }
recount_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# ... <note>+company is edited
ensure_set { TypePlusRight::Claim::WikirateCompany }
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end
