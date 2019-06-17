include_set Right::BrowseTopicFilter

def filter_keys
  # don't show company filter (already filtering by current company)
  super - [:wikirate_company]
end