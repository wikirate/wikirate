def count
  Auth.as_bot { Card.search right: :account, return: :count }
end

def count_label
  "Data contributors"
end
