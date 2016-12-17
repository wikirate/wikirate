def virtual?
  true
end

def raw_ruby_query
  { type_id: ProjectID, right_plus: [OrganizerID, refer_to: "_left"] }
end
