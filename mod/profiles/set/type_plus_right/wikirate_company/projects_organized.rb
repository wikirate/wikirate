def wql_content
  {
    type_id: ProjectID,                                # find projects
    right_plus: [
      OrganizerID,                                     # whose organizer
      refer_to: {
        or: [                                          # is either
          { found_by: left.research_group_card.name }, # a group the company organized
          name.left                                    # or the company itself
        ]
      }
    ]
  }
end
