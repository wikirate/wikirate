assign_type :search_type

def virtual?
  new?
end

def cql_content
  { right_plus: [:badges_earned, { refer_to: left_id }], sort: :name, return: "_left" }
end

def item_cards _args
  super.map(&:left)
end
