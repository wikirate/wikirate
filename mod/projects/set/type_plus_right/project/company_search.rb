def project_name
  name.left_name
end

def pointer_name
  project_name.field :wikirate_company
end

def wql_content
  {
    type: WikirateCompanyID,
    referred_to_by: pointer_name,
    append: project_name
  }
end
