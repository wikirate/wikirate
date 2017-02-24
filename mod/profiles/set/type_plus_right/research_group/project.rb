def virtual?
  true
end

def wql_hash
  { type_id: ProjectID, right_plus: [OrganizerID, refer_to: "_left"] }
end
