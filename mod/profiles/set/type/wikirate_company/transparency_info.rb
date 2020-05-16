format :json do
  view :transparency_info do
    card.holding_company.transparency_info.to_json
  end
end

def transparency_info
  {
      holding: name,
      location: location,
      number_of_workers: number_of_workers,
      brands: all_brands,
      scores: scores,
      contact_url: contact_url,
      suppliers: supplier_infos,
  }
end

def holding_company?
  true
end

def holding_company
  if (holding = related_companies(metric: :commons_has_brands, inverse: true)).present?
    holding.first
  else
    self
  end
end

def number_of_workers
  latest_answer(metric: :ccc_number_of_workers)
end

def location
  latest_answer(metric: :core_headquarters_location)&.value
end

def all_brands
  related_company_names(metric: :commons_has_brands)
end

def scores
  {
      transparency: transparency_score,
      commitment: commitment_score,
      living_wage: living_wage_score
  }
end

def transparency_score
  4
end

def commitment_score
  { total: 4,
    public_commitment: "yes",
    action_plan: "partial",
    fing_fencing_labour_cost: "no"
  }
end

def living_wage_score
  2
end

def contact_url
  "http://action.com"
end

def suppliers
  related_companies(metric: :commons_supplied_by)
end

def supplier_infos
  suppliers.map(&:supplier_info)
end