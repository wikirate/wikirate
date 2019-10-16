# Eg MyProject+Company+Project
# Returns <Company>+<Project> cards for MyProject.  Makes listings pageable

def item_type
  pointer_name.right
end

def project_name
  pointer_name.left
end

def pointer_name
  name.left_name
end

def wql_content
  {
    type: item_type,
    referred_to_by: pointer_name,
    append: project_name
  }
end
