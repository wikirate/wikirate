assign_type :search

def cql_content
  { type: :reference, right_plus: [:subject, refer_to: "_left"] }
end
