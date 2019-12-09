def report_query action, user_id, subvariant
  standard_report_query.merge send("#{action}_query", user_id, subvariant)
end

def standard_report_query
  { type_id: id, limit: 5 }
end

def created_query user_id, _variant=nil
  { created_by: user_id }
end

def updated_query user_id, _variant=nil
  { updated_by: user_id }
  # standard_report_count or: [
  #   { edited_by: user_id },
  #   { right_plus: [{}, edited_by: user_id]}
  # ]
end

def discussed_query user_id, _variant=nil
  { right_plus: [Card::DiscussionID,
                 { edited_by: user_id }] }
end

def bookmarked_query user_id, _variant=nil
  { linked_to_by: { left_id: user_id, right_id: Card::BookmarksID } }
end

def double_checked_query user_id, _variant=nil
  { right_plus: [CheckedByID, { refer_to: { id: user_id } }] }
end

def subvariants
  {}
end

# [ :metric_answer, :metric, :wikirate_company, :project ]
#
# project
# - RG is organizer
#   (+organizer refers to _self)
#
# company
# - RG is organizer of project researching company
#   (referred to by +company on projects where +organizer refers to _self)
#
# metric
# - RG is organizer of project researching metric
#   (referred to by +metric on projects where +organizer refers to _self)
#
# -- OR --
#
# - metrics where RG is designer
#   (left of metric is _self)
#
# metric value
# - company is among companies above AND metric is among metrics above
#
#
#
#
#
