include_set Abstract::BrowseNotesAndSourcesFilterForm

def filter_keys
  %w(name cited wikirate_company wikirate_topic)
end

def target_type_id
  ClaimID
end
