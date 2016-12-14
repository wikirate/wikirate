format do
  def default_header_args _args
    voo.variant = :plural
  end
end

def report_query action, user_id
  standard_report_query.merge send("#{action}_query", user_id)
end

def research_group_report_query action, user_id, _project_id
  report_query action, user_id
end

def created_query user_id
  { created_by: user_id }
end

def updated_query user_id
  { edited_by: user_id }
  # standard_report_count or: [
  #   { edited_by: user_id },
  #   { right_plus: [{}, edited_by: user_id]}
  # ]
end

def discussed_query user_id
  { right_plus: [Card::DiscussionID,
                 { edited_by: user_id }] }
end

def voted_on_query user_id
  { linked_to_by: { left_id: user_id,
                    right_id: [:in, UpvotesID, DownvotesID] } }
end

def standard_report_query
  { type_id: id, limit: 5 }
end


=begin
[ :metric_value, :metric, :wikirate_company, :project ]

project
- RG is organizer
  (+organizer refers to _self)

company
- RG is organizer of project researching company
  (referred to by +company on projects where +organizer refers to _self)

metric
- RG is organizer of project researching metric
  (referred to by +metric on projects where +organizer refers to _self)

# -- OR --
#
# - metrics where RG is designer
#   (left of metric is _self)

metric value
- company is among companies above AND metric is among metrics above





=end

