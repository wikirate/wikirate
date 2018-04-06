def virtual?
  true
end

def content
  %({
    "found_by":"_left",
    "not":{
      "linked_to_by":{
        "left":"_user",
        "right_id":["in","#{UpvotesID}","#{DownvotesID}"]
      }
    },
    "return":"name",
    "limit":"0"
  })
end

def vote_type
  :no_vote
end

def vote_type_codename
  :novotes
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
    list_with_no_session_votes
  end

  def list_with_no_session_votes
    result = super_search_results
    [:up_vote, :down_vote].each do |bucket|
      next unless Env.session[bucket]
      result.reject! do |votee_plus_drag_item|
        votee_name = votee_plus_drag_item.to_name
        (votee_id = Card.fetch_id(votee_name)) && Env.session[bucket].include?(votee_id)
      end
    end
    result
  end
end

format :html do
  include Right::DownvoteeSearch::HtmlFormat

  def default_filter_and_sort_args _args
    @default_sort ||=
      if main_type_id == WikirateCompanyID &&
         searched_type_id == WikirateTopicID
        :contributions
      else
        :importance
      end
  end
end
