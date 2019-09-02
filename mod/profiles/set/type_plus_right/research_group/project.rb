def virtual?
  new?
end

def wql_content
  { type_id: ProjectID, right_plus: [OrganizerID, refer_to: "_left"] }
end
