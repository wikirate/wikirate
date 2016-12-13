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
  #   { edited_by: user_id },
  #   { right_plus: [{}, edited_by: user_id]}
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

