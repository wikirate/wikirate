include_set Right::BrowseMetricFilter

def filter_keys
  super - [:wikirate_topic]
end
