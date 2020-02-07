def wql_content
  {
    type_id: Card::ProjectID,                                # find projects
    right_plus: [
      Card::OrganizerID,                                     # whose organizer
      refer_to: {
        or: [                                          # is either
          { found_by: left.research_group_card.name }, # a group the company organized
          name.left                                    # or the company itself
        ]
      }
    ]
  }
end
