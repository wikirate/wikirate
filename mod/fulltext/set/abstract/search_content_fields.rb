def content_for_search
  content_for_search_from_fields
end

def search_content_cards
  search_content_field_codes.map do |code|
    fetch code, new: {}
  end.compact
end

def search_content_field_names
  search_content_field_codes.map do |code|
    name.trait_name code
  end
end
