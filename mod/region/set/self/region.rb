def countries_by_code
  Card::Region.lookup_val(:country_code).sort_by { |_id, code| code }
end

format :json do
  def country_hash_list
    card.countries_by_code.map do |region_id, country_code|
      { "code": country_code, name: region_id.cardname, card_id: region_id }
    end
  end

  view :countries do
    country_hash_list.to_json
  end

  view :pretty_countries do
    JSON.pretty_generate country_hash_list
  end
end
