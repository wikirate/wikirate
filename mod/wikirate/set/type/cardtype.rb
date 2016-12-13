format do
  def default_header_args _args
    voo.variant = :plural
  end
end

def created_report_content user_id
  standard_report_wql created_by: user_id
end

def updated_report_content user_id
  standard_report_wql edited_by: user_id
  # standard_report_count or: [
  #   { edited_by: user_card.id },
  #   { right_plus: [{}, edited_by: user_card.id]}
  # ]
end

def discussed_report_content user_id
  standard_report_wql right_plus: [Card::DiscussionID,
                                   { edited_by: user_id }]
end

def voted_on_report_content user_id
  standard_report_wql linked_to_by: {
    left_id: user_id, right_id: [:in, UpvotesID, DownvotesID]
  }
end

def standard_report_wql args
  JSON.generate({ type_id: id, limit: 5 }.merge(args))
end

