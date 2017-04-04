include_set Abstract::CachedCount
include_set Abstract::WqlSearch

def virtual?
  true
end

def wql_search
  { type_id: ProjectID, right_plus:[WikirateCompanyID, { refer_to: left.id }] }
end

ensure_set { TypePlusRight::Project::WikirateCompany }

recount_trigger TypePlusRight::Project::WikirateCompany do |changed_card|
  names = Abstract::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |company_name|
    Card.fetch company_name.to_name.trait(:project)
  end
end
