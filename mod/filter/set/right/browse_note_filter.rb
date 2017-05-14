include_set Abstract::BrowseNotesAndSourcesFilterForm

def filter_keys
  %w[name wikirate_company wikirate_topic]
end

def target_type_id
  ClaimID
end

def default_sort_option
  "important"
end

format :html do
  def sort_options
    super.merge "Most Important" => "important",
                "Most Recent" => "recent"
  end
end
