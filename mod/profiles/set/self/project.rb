def subvariants
  { created: [:submitted, :organized] }
end

def created_query user_id, variant=nil
  case variant
  when :submitted
    { created_by: user_id }
  when :organized
    { right_plus: [OrganizerID, { refer_to: user_id }] }
  else
    { or:
        created_query(user_id, :submitted).merge(
          created_query(user_id, :organized)
        ) }
  end
end

def discussed_query user_id, _variant=nil
  {
    or: super(user_id).merge(
      referred_to_by: { right_id: ProjectID,
                        left: {
                          type_id: ConversationID,
                          right_plus: [DiscussionID, { edited_by: user_id }]
                        } }
    )
  }
end
