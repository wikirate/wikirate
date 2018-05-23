def virtual?
  true
end

def content
  if (ll = left.left) && ll.type_id == WikirateTopicID &&
     left.right.id == WikirateCompanyID
    # FIXME: this is an ugly hack to get topic pages working (were overwhelmed by company counts)
    # FIXME - cardnames!!!
    %(
      { "type":"Company",
        "referred_to_by":{
          "left":{
            "type":["in","Note","Source"],
            "right_plus":["topic",{"refer_to":"_1"}]
          },
          "right":"company"
        },
        "limit":"0",
        "return":"name"
      }
    )
  else
    '{"type":"_lr", "limit":0,"return":"name"}'
  end
end

def vote_type
  :no_vote
end

def vote_label
  nil
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

  before :filter_and_sort do
    @default_sort ||=
      if main_type_id == WikirateTopicID && searched_type_id == WikirateCompanyID
        :contributions
      else
        :importance
      end
  end
end
