# Eg MyDataset+Company+Dataset
# Returns <Company>+<Dataset> cards for MyDataset.  Makes listings pageable

include_set Type::SearchType

def virtual?
  new?
end

def item_type
  pointer_name.right
end

def dataset_name
  pointer_name.left
end

def pointer_name
  name.left_name
end

def cql_content
  {
    type: item_type,
    referred_to_by: pointer_name,
    append: dataset_name,
    sort: :name,
    limit: 100
  }
end
