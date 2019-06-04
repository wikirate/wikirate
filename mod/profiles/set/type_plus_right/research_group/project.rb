def virtual?
  new?
end

def wql_from_content
  { type_id: ProjectID, right_plus: [OrganizerID, refer_to: "_left"] }
end
