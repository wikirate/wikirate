def wql_content
  { type_id: ProjectID,
    right_plus: [OrganizerID,
                 { refer_to: [:in, "_left"] + left.research_group_card.item_names }] }
end
