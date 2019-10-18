def project_name
  name.left_name
end

def pointer_mark
  project_name.field :wikirate_company
end

def wql_content
  super.merge append: project_name
end
