# cache # of sources tagged with this company (=_left)
include Card::CachedCount

ensure_set  { TypePlusRight::Source::WikirateCompany }

# needs update if company list of a source has changed
expired_cached_count_cards set: TypePlusRight::Source::WikirateCompany do |changed_card|
  changed_card.item_names.map do |company_name|
    Card.fetch "#{company_name}+#{Card[:source].name}"
  end
end
