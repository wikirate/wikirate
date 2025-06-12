assign_type :search_type

def virtual?
  new?
end

def cql_content
  { type: :project, right_plus: [:dataset, { refer_to: "_left" }] }
end
