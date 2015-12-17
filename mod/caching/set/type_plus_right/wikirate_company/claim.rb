# cache # of claims tagged with this company (=_left)
include Card::CachedCount

ensure_set { TypePlusRight::Claim::WikirateCompany }
expired_cached_count_cards(
  set: TypePlusRight::Claim::WikirateCompany
) do |changed_card|
  # FIXME: we don't catch deletions of companies
  changed_card.item_cards.map do |company|
    company.fetch trait: :claim
  end
end
