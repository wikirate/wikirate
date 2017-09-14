include_set Abstract::SortAndFilter

def item_cards
  left.related_companies.map { |id| Card[id] }
end

def item_names
  left.related_companies.map { |id| id.cardname.s }
end

def related_company_ids_to_json ids
  ids.each_with_object({}) do |company_id, result|
    result[company_id] = true unless result.key?(company_id)
  end.to_json
end

format :json do
  view :core do
    card.related_company_ids_to_json card.left.related_companies
  end
end

format do
  def analysis_cached_count company, type
    search_card = Card.fetch "#{company}+#{card.cardname.left}+#{type}"
    return 0 unless search_card
    search_card.cached_count
  end
end
