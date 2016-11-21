include Card::CachedCount

ensure_set { TypePlusRight::Project::WikirateCompany }

recount_trigger TypePlusRight::Project::WikirateCompany do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |company_name|
    Card.fetch company_name.to_name.trait(:project)
  end
end
