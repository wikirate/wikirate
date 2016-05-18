include Right::DownvoteeSearch

def vote_type
  :up_vote
end

def vote_type_codename
  :upvotes
end

def vote_label
  "Important to Me"
end

format do
  include Right::DownvoteeSearch::Format
end

format :html do
  include Right::DownvoteeSearch::HtmlFormat

  def default_drag_and_drop_args args
    args[:query] = "vote=force-up"
    super(args)
  end
end
