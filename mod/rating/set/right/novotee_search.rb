def virtual?; true end

def raw_content
  '{"type":"_r","not":{"linked_to_by":{"left":"_user","right":["in","*upvotes","*downvotes"]}}, "limit":0}'
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
    list_with_no_session_votes
  end

  def list_with_no_session_votes
    result = super_search_results
    [:up_vote, :down_vote].each do |bucket|
      if Env.session[bucket]
        result.reject! do |votee_plus_drag_item|
          votee_name = votee_plus_drag_item.to_name.left
          (votee_id = Card.fetch_id(votee_name)) && Env.session[bucket].include?(votee_id)
        end
      end
    end
    result
  end
end

format :html do
  include Right::DownvoteeSearch::HtmlFormat
  def default_drag_and_drop_args args
    args[:query] ||= 'vote=force-neutral'
    args[:unsaved] ||= ''
    args[:default_sort] ||=
      if card[1].id == WikirateTopicID || card[1].id == WikirateCompanyID
        :contributions
      else
        :importance
      end
    super(args)
  end

end