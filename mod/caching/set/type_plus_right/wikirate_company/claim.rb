# cache # of claims tagged with this company (=_left)
include Card::CachedCount

ensure_set { TypePlusRight::Claim::WikirateCompany }

# recount no. of notes associated with a company when <note>+company is edited
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |company_name|
    Card.fetch company_name.to_name.trait(:claim)
  end
end
