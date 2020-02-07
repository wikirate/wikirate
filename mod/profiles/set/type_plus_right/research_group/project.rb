def virtual?
  new?
end

def wql_content
  { type_id: Card::ProjectID, right_plus: [Card::OrganizerID, refer_to: "_left"] }
end
