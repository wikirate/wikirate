def analysis_names
  return [] unless (topics = fetch(trait: :wikirate_topic)) &&
      (companies = fetch(trait: :wikirate_company))
  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company.to_name.tag}+#{topic}"
    end
  end.flatten
end