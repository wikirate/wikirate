def virtual?; true end

def raw_content
  '{"type":"_r","linked_to_by":{"left":"_user","right":"*upvotes"}, "limit":0}'
end

def vote_type
  :up_vote
end

def sort_by
  'upvotes'
end

format do
  include Right::DownvoteeSearch::Format
end

format :html do
  include Right::DownvoteeSearch::HtmlFormat

  def default_drag_and_drop_args args
    args[:query] = 'vote=force-up'
    super(args)
  end
end