assign_type :list

def option_names
  Card.search type: :blurb, return: :name
end
