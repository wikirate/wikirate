include_set Right::BrowseCompanyFilter

def wql_content
  {
    type_id: WikirateCompanyID,
    referred_to_by: left.id,
  }
end