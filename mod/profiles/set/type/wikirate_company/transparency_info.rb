format :json do
  view :transparency_info do
    card.holding_company.transparency_info.to_json
  end
end

def transparency_info
  {
      id: id,
      holding: name,
      address: address,
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
  latest_answer :ccc_number_of_workers
end

def address
  latest_value(:ccc_address)
end

def location
  latest_value :core_headquarters_location
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
  latest_value :ccc_supply_chain_transparency_score
end

def commitment_score
  { total: latest_value(:ccc_policy_promise_score),
    public_commitment: "yes",
    action_plan: "partial",
    fing_fencing_labour_cost: "no"
  }
end

def living_wage_score
  latest_value :ccc_living_wages_paid_score
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