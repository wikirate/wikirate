def virtual?; true end

def raw_content
  if self[0].type_id == WikirateCompanyID && cardname.left_name.right_name.key == 'metric'  # find only metrics with values
    '{"type":"_lr","right_plus":["_1",{"right_plus":["*cached count",{"content":["ne","0"]}]}], "not":{"linked_to_by":{"left":"_user","right":["in","*upvotes","*downvotes"]}}, "limit":0, "return":"name"}'
  else
    '{"type":"_lr","not":{"linked_to_by":{"left":"_user","right":["in","*upvotes","*downvotes"]}}, "limit":0, "return":"name"}'
  end
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
      if Env.session[bucket]
        result.reject! do |votee_plus_drag_item|
          votee_name = votee_plus_drag_item.to_name
          (votee_id = Card.fetch_id(votee_name)) && Env.session[bucket].include?(votee_id)
        end
      end
    end
    result
  end
end

format :html do
  include Right::DownvoteeSearch::HtmlFormat

  def default_filter_and_sort_args args
    args[:default_sort] ||=
      if main_type_id == WikirateCompanyID &&
         searched_type_id == WikirateTopicID
        :contributions
      else
        :importance
      end
  end

  def default_drag_and_drop_args args
    default_filter_and_sort_args(args)
    args[:query] ||= 'vote=force-neutral'
    args[:unsaved] = nil
    super(args)
  end

end