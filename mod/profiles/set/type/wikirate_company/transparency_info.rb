format :json do
  view :transparency_info do
    if !holding_company
      holding_company.transparency_info
    else
      transparency_info
    end
  end

  def transparency_info
    {
        holding: card.name,
        location: location,
        brands: all_brands,
        scores: scores,
        contact_url: contact_url,
        suppliers: supplier_infos,
    }.to_json
  end

  def holding_company?
    true
  end

  def holding_company
    card
  end

  def location
    "Berlin"
  end

  def all_brands
    ["Coca Cola", "Google"]
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
    [
        Card["Apple Inc"],
        Card["Google Inc"]
    ]
  end

  def supplier_infos
    suppliers.map { |supplier| subformat(supplier).render(:supplier_info)}
  end
end