include_set Right::BrowseMetricFilter

# def sort_hash
#   sort_wql
# end

def filter_keys
  super - [:wikirate_topic]
end
