include_set Abstract::BrowseNotesAndSourcesFilterForm

def filter_keys
  %w(wikirate_company wikirate_topic)
end

def target_type_id
  SourceID
end

def sort_options
  super.merge "Most Recent" => "recent"
end
