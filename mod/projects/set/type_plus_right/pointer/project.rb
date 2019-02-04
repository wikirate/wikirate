# Eg MyProject+Metrics+Project
# Returns Metric+Project cards for MyProject.  Makes listings pageable

include_set Type::SearchType

def virtual?
  true
end

def item_type
  pointer_name.right
end

def project_name
  pointer_name.left
end

def pointer_name
  name.left_name
end

def wql_hash
  {
    type: item_type,
    referred_to_by: pointer_name,
    append: project_name,
    sort: :name,
    limit: 50
  }
end
