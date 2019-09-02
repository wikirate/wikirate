include_set Abstract::WqlSearch

def virtual?
  new?
end

def content
  %({
    "type":"_lr",
    "linked_to_by":"_user+#{Card.fetch_name vote_type_codename}",
    "limit":0,
    "return":"name"
  })
end

def vote_type
  :down_vote
end

def vote_type_codename
  :downvotes
end

def vote_label
  # should be card content
  "Not Important to Me"
end

def sort_by
  vote_type_codename
end

format do
  include Type::SearchType::Format

  alias_method :super_search_results, :search_with_params

  def search_with_params
    @search_results ||= get_search_result
  end

  def get_search_result
    if !Auth.signed_in?
      get_result_from_session
    elsif vote_order
      super_search_results.sort do |x, y| # super returns array with votee cards
        vote_order[x] <=> vote_order[y]
      end
    else
      super_search_results
    end
  end

  def vote_order
    @vote_order ||=
      if card.sort_by && (vote_card = Auth.current.fetch trait: card.sort_by)
        votee_items = vote_card.item_names
        super_search_results.each_with_object({}) do |name, hash|
          hash[name] = votee_items.index "~#{Card.fetch_id(name)}"
        end
      end
  end

  def get_result_from_session
    list_with_session_votes
  end

  def list_with_session_votes
    if Env.session[card.vote_type]
      Env.session[card.vote_type].map do |votee_id|
        found_votee_card =
          Card.find_by_id_and_type_id(votee_id, searched_type_id)
        found_votee_card ? found_votee_card.name : ""
      end.compact.reject(&:empty?)
    else
      []
    end
  end
end
