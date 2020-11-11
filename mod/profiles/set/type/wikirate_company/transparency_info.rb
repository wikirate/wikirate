format :json do
  view :transparency_info do
    card.transparency_info(card.name).to_json
  end

  view :transparency_info_short do
    card.transparency_info_short(card.name).to_json
  end
end

def transparency_info_short company_name
  {
    id: id,
    owned_by: name,
    name: company_name,
    scores: scores,
    contact_url: contact_url
  }
end

def transparency_info company_name
  transparency_info_short(company_name).merge(
    logo: logo_url,
    address: address,
    location: location,
    number_of_workers: number_of_workers,
    top_production_countries: latest_value(:ccc_top_production_countries),
    revenue: latest_number(:ccc_revenue),
    profit: latest_number(:ccc_profit),
    brands: all_brands,
    suppliers: supplier_infos,
    twitter_handle: twitter_handle
  )
end

def logo_url
  image_card&.image&.url
end

def latest_number key
  return unless (num = latest_value key)

  format.number_with_delimiter num
end

# def holding_company
#   if (holding = related_companies(metric: :commons_has_brands, inverse: true)).present?
#     holding.first
#   else
#     self
#   end
# end

def number_of_workers
  latest_answer :ccc_number_of_workers
end

def address
  latest_value :ccc_address
end

def twitter_handle
  latest_value :ccc_twitter_handle
end

def location
  latest_value :core_headquarters_location
end

def all_brands
  related_company_names metric: :commons_has_brands
end

def scores
  {
    transparency: transparency_score,
    commitment: commitment_score,
    living_wage: living_wage_score,
    transparency_text: transparency_score_text,
    living_wage_text: living_wage_score_text,
    transparency_key: transparency_score_key,
    living_wage_key: living_wage_score_key
  }
end

def transparency_score
  latest_value :ccc_supply_chain_transparency_score
end

def transparency_score_text
  latest_value :ccc_supply_chain_transparency_score_text
end

def transparency_score_key
  latest_value :ccc_supply_chain_transparency_score_key
end

def commitment_score
  {
    total: latest_value(:ccc_policy_promise_score),
    public_commitment: latest_value(:ccc_public_commitment),
    action_plan: latest_value(:ccc_action_plan),
    isolating_labour_cost: latest_value(:ccc_isolating_labour_cost)
  }
end

def living_wage_score
  latest_value :ccc_living_wages_paid_score
end

def living_wage_score_text
  latest_value :ccc_living_wages_paid_score_text
end

def living_wage_score_key
  latest_value :ccc_living_wages_paid_score_key
end

def contact_url
  "http://action.com"
end

def suppliers
  related_companies(metric: :commons_supplied_by)
end

def supplier_infos
  suppliers.map(&:supplier_info).sort_by { |a, b| a[:sort_key] <=> b[:sort_key] }
end
