format :json do
  view :countries do
    # FIXME: country code needs codename!
    Wikirate::Region.region_lookup("Country Code").map do |region_id, country_code|
      { "code": country_code, name: region_id.cardname }
    end.to_json
  end
end
