include_set Right::BrowseCompanyFilter

def default_sort_option
  "name"
end

def pointer_mark
  name.left
end

def wql_content
  { type_id: WikirateCompanyID, referred_to_by: pointer_mark }
end
