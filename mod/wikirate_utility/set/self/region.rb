def countries_by_code
  # FIXME: country code needs codename!
  Wikirate::Region.region_lookup("Country Code").sort_by { |_id, code| code }
end

format :json do
  view :countries do
    array = card.countries_by_code.map do |region_id, country_code|
      { "code": country_code, name: region_id.cardname }
    end
    JSON.pretty_generate array
  end
end
