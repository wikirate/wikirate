include_set Type::SearchType

def virtual?
  new?
end

def cql_content
  { type: :dataset, right_plus: [:parent, { refer_to: "_left" }] }
end
