def virtual?; true end

def raw_content
  if left.left.type_id == WikirateTopicID && left.right.id == WikirateCompanyID
    # FIXME this is an ugly hack to get topic pages working (were overwhelmed by company counts)
    %(
      { "type":"Company",
        "referred_to_by":{
          "left":{
            "type":["in","Claim","Source"],
            "right_plus":["topic",{"refer_to":"_1"}]
          },
          "right":"company"
        },
        "limit":"0"
      }
    )
  else
    '{"type":"_r", "limit":0}'
  end
end

def vote_type
  :no_vote
end

def sort_by
  false
end

format do
  include Right::DownvoteeSearch::Format
  def get_result_from_session
    super_search_results
  end
end

format :html do
  include Right::DownvoteeSearch::HtmlFormat

  def default_filter_and_sort_args args
    args[:unsaved] ||= ''
    args[:default_sort] ||=
      if main_type_id == WikirateTopicID && searched_type_id == WikirateCompanyID
        :contributions
      else
        :importance
      end
  end
end
