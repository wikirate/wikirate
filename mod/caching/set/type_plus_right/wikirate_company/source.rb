# cache # of sources tagged with this company (=_left)
include Card::CachedCount

ensure_set { Source::WikirateCompany }

# needs update if company list of a source has changed
recount_trigger Source::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch company_name.to_name.trait(:source)
  end
end
