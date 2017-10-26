include_set Abstract::BrowseNotesAndSourcesFilterForm

def filter_keys
  %i[wikirate_company wikirate_topic]
end

def target_type_id
  SourceID
end

def default_sort_option
  "recent"
end

format :html do
  def sort_options
    super.merge "Most Recent" => "recent"
  end
end
