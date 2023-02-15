def cql_content
  {
    type: :project,                                 # find projects
    right_plus: [
      :organizer,                                   # whose organizer
      refer_to: left_id                             # is (_left)
    ]
  }
end
