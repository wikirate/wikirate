include_set Abstract::OrganizerQueries

def discussed_query user_id, _variant=nil
  {
    or: super(user_id).merge(
      referred_to_by: { right_id: Card::ProjectID,
                        left: {
                          type_id: Card::ConversationID,
                          right_plus: [Card::DiscussionID, { edited_by: user_id }]
                        } }
    )
  }
end
