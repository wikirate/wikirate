format do
  def default_header_args _args
    voo.variant = :plural
  end
end

def created_report_query user_id
  standard_report_query created_by: user_id
end

def updated_report_query user_id
  standard_report_query edited_by: user_id
  # standard_report_count or: [
  #   { edited_by: user_card.id },
  #   { right_plus: [{}, edited_by: user_card.id]}
  # ]
end

def discussed_report_query user_id
  standard_report_query right_plus: [Card::DiscussionID,
                                   { edited_by: user_id }]
end

def voted_on_report_query user_id
  standard_report_query linked_to_by: {
    left_id: user_id, right_id: [:in, UpvotesID, DownvotesID]
  }
end

def standard_report_query args
  { type_id: id, limit: 5 }.merge(args)
end

def standard_project_report_query args
end
