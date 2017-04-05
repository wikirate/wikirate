# cache # of notes tagged with this company (=_left)
include_set Abstract::CachedCount
include_set Abstract::WqlSearch

def virtual?
  true
end

def wql_search
  { type_id: ClaimID, right_plus: [WikirateCompanyID, {refer_to: left.id }] }
end

ensure_set { TypePlusRight::Claim::WikirateCompany }
# recount no. of notes associated with a company when <note>+company is edited
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  names = Abstract::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |company_name|
    Card.fetch company_name.to_name.trait(:claim)
  end
end
