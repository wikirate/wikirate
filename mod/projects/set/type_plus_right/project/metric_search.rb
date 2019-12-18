def project_name
  name.left_name
end

def pointer_mark
  project_name.field :metric
end

def wql_content
  super.merge append: project_name
end
