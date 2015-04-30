def virtual?; true end

def raw_content
  '{"type":"_r", "limit":0}'
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

  def default_drag_and_drop_args args
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